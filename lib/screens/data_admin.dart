import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:purelux/screens/detail_karyawan_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataAdminScreen extends StatefulWidget {
  const DataAdminScreen({super.key});

  @override
  State<DataAdminScreen> createState() => _DataAdminScreenState();
}

class _DataAdminScreenState extends State<DataAdminScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> employees = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final QuerySnapshot querySnapshot =
          await _firestore.collection('user').get();
      if (!mounted) return;

      setState(() {
        employees = querySnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading employees: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Terjadi kesalahan saat memuat data. Silakan coba lagi.';
      });
    }
  }

  Future<void> _createEmployee({
    required String email,
    required String password,
    required String name,
    required String position,
  }) async {
    if (!mounted) return;

    try {
      // Validasi email
      if (!email.contains('@')) {
        throw 'Format email tidak valid';
      }

      // Validasi password
      if (password.length < 6) {
        throw 'Password harus minimal 6 karakter';
      }

      // Simpan credential admin saat ini
      final adminUser = _auth.currentUser;
      print('Current admin user: $adminUser');
      if (adminUser == null) {
        throw 'Sesi admin tidak ditemukan';
      }

      // Dapatkan data admin dari Firestore
      final adminDoc =
          await _firestore.collection('user').doc(adminUser.uid).get();
      print('Admin document exists: ${adminDoc.exists}');
      print('Admin document data: ${adminDoc.data()}');
      if (!adminDoc.exists) {
        throw 'Data admin tidak ditemukan';
      }
      final adminData = adminDoc.data()!;
      print('Admin email: ${adminData['email']}');
      print('Admin password exists: ${adminData.containsKey('password')}');
      final adminEmail = adminData['email'] as String;
      final adminPassword = adminData['password'] as String;

      print('Creating new user with email: $email');
      // Buat user baru di Authentication
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid;
      print('New user created with ID: $userId');

      // Simpan data di Firestore
      await _firestore.collection('user').doc(userId).set({
        'id': userId,
        'username': name,
        'email': email,
        'role': position,
        'password': password,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('User data saved to Firestore');

      print('Attempting to log back in as admin - Email: $adminEmail');
      // Login kembali sebagai admin
      await _auth.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );
      print('Successfully logged back in as admin');

      // Reload employees list
      if (!mounted) return;
      await _loadEmployees();

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Karyawan berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Detailed error during user creation: $e');
      if (e is FirebaseAuthException) {
        print('Firebase Auth Error Code: ${e.code}');
        print('Firebase Auth Error Message: ${e.message}');
      }

      // Jika terjadi error, coba login ulang sebagai admin
      try {
        print('Attempting to recover admin session...');
        final adminDoc = await _firestore
            .collection('user')
            .where('role', isEqualTo: 'admin')
            .limit(1)
            .get();

        print('Found admin documents: ${adminDoc.docs.length}');
        if (adminDoc.docs.isNotEmpty) {
          final adminData = adminDoc.docs.first.data();
          print('Retrieved admin data: ${adminData.toString()}');
          print('Admin email from recovery: ${adminData['email']}');
          print(
              'Admin password exists in recovery: ${adminData.containsKey('password')}');

          await _auth.signInWithEmailAndPassword(
            email: adminData['email'],
            password: adminData['password'],
          );
          print('Successfully recovered admin session');
        }
      } catch (loginError) {
        print('Error saat login ulang admin: $loginError');
      }

      if (!mounted) return;

      // Menerjemahkan pesan error
      String errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';

      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'Email sudah terdaftar';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Format email tidak valid';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'Password terlalu lemah';
      } else if (e.toString().contains('network-request-failed')) {
        errorMessage = 'Koneksi internet bermasalah';
      } else if (e is String) {
        errorMessage = e;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Terjadi kesalahan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.red[300],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadEmployees,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF001F3D),
            ),
            child: Text(
              'Coba Lagi',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data karyawan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Data Karyawan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployees,
            tooltip: "Refresh Data",
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddEmployeeDialog,
            tooltip: "Tambah Karyawan",
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF001F3D), Color(0xFFFFFFFF)],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorWidget()
                : employees.isEmpty
                    ? _buildEmptyWidget()
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const AbsensiPieChart(),
                          const SizedBox(height: 20),
                          ...employees.map((employee) {
                            return Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF001F3D),
                                  child: Text(
                                    employee["username"] != null &&
                                            employee["username"]!.isNotEmpty
                                        ? employee["username"]![0]
                                        : '',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  employee["username"] ?? "",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                subtitle: Text(
                                  "${employee["role"]} - ${employee["email"]}",
                                  style: GoogleFonts.poppins(
                                      fontSize: 13, color: Colors.black),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 16, color: Colors.black),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailKaryawanScreen(data: employee),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                        ],
                      ),
      ),
    );
  }

  void _showAddEmployeeDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedPosition = 'karyawan'; // Default value

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Tambah Karyawan', style: GoogleFonts.poppins()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInputField('Nama', nameController),
                const SizedBox(height: 10),
                _buildInputField('Email', emailController),
                const SizedBox(height: 10),
                _buildInputField('Password', passwordController,
                    isPassword: true),
                const SizedBox(height: 10),
                StatefulBuilder(
                  builder: (context, setState) {
                    return SizedBox(
                      height: 60,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Jabatan',
                          labelStyle: GoogleFonts.poppins(),
                          prefixIcon:
                              Icon(Icons.work, color: Color(0xFF001F3D)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedPosition,
                            isDense: true,
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down,
                                color: Color(0xFF001F3D)),
                            dropdownColor: Colors.white,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            items: ['admin', 'karyawan'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style:
                                      GoogleFonts.poppins(color: Colors.black),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedPosition = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Batal',
                  style: TextStyle(color: const Color(0xFF001F3D))),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF001F3D),
                foregroundColor: Colors.white,
              ),
              child: Text('Simpan', style: GoogleFonts.poppins()),
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Semua field harus diisi'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                await _createEmployee(
                  email: emailController.text.trim(),
                  password: passwordController.text,
                  name: nameController.text.trim(),
                  position: selectedPosition,
                );

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    IconData icon;

    if (label == 'Nama') {
      icon = Icons.person;
    } else if (label == 'Email') {
      icon = Icons.email;
    } else if (label == 'Password') {
      icon = Icons.lock;
    } else {
      icon = Icons.input;
    }

    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        prefixIcon: Icon(icon, color: Color(0xFF001F3D)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
}

class AbsensiPieChart extends StatelessWidget {
  const AbsensiPieChart({super.key});

  Future<Map<String, double>> fetchAbsensiData() async {
    final firestore = FirebaseFirestore.instance;

    // Jumlah Hadir = jumlah dokumen di koleksi absensi
    final hadirSnapshot = await firestore.collection('absensi').get();
    final double jumlahHadir = hadirSnapshot.docs.length.toDouble();

    // Jumlah Izin
    final izinSnapshot = await firestore
        .collection('pengajuan')
        .where('jenis', isEqualTo: 'izin')
        .where('status', isEqualTo: 'Disetujui')
        .get();
    final double jumlahIzin = izinSnapshot.docs.length.toDouble();

    // Jumlah Cuti
    final cutiSnapshot = await firestore
        .collection('pengajuan')
        .where('jenis', isEqualTo: 'cuti')
        .where('status', isEqualTo: 'Disetujui')
        .get();
    final double jumlahCuti = cutiSnapshot.docs.length.toDouble();

    return {
      'Hadir': jumlahHadir,
      'Izin': jumlahIzin,
      'Cuti': jumlahCuti,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: fetchAbsensiData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text("Terjadi kesalahan"));
        }

        final data = snapshot.data!;
        final absensiData = [
          {"label": "Hadir", "value": data['Hadir'] ?? 0, "color": Colors.blue},
          {
            "label": "Terlambat",
            "value": data['Terlambat'] ?? 0,
            "color": Colors.orange
          },
          {"label": "Izin", "value": data['Izin'] ?? 0, "color": Colors.green},
          {"label": "Cuti", "value": data['Cuti'] ?? 0, "color": Colors.yellow},
          {"label": "Alpha", "value": data['Alpha'] ?? 0, "color": Colors.red},
        ];

        return Card(
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ----------- TANGGAL & TOMBOL -----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Selasa, 07 Januari 2023",
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.black),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Aksi tombol lihat semua
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Lihat Semua Data"),
                            content: const Text(
                                "Detail data absensi bisa ditampilkan di sini."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Tutup"),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                      ),
                      child: Text("Lihat Semua",
                          style: GoogleFonts.poppins(fontSize: 12)),
                    ),
                  ],
                ),

                const SizedBox(height: 35),
                // ----------- CHART & LEGENDA -----------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: AspectRatio(
                        aspectRatio: 1.2,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                centerSpaceRadius: 50,
                                sectionsSpace: 2,
                                centerSpaceColor: Colors.white,
                                sections: absensiData
                                    .where((e) => (e['value'] as double) > 0)
                                    .map((e) => PieChartSectionData(
                                          color: e['color'] as Color,
                                          value: e['value'] as double,
                                          title: '',
                                          radius: 40,
                                        ))
                                    .toList(),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${data['BelumAbsen']?.toInt() ?? 0}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  'Belum Absen',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: absensiData.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: entry['color'] as Color,
                                  radius: 5,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  entry['label'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                // ----------- ANGKA STATISTIK -----------
                Column(
                  children: absensiData.map((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e['label'] as String,
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.black),
                          ),
                          Text(
                            "${(e['value'] as double).toInt()}",
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.black),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
