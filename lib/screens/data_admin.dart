import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:purelux/screens/detail_karyawan_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

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
      // ignore: avoid_print
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
      // ignore: avoid_print
      print('Current admin user: $adminUser');
      if (adminUser == null) {
        throw 'Sesi admin tidak ditemukan';
      }

      // Dapatkan data admin dari Firestore
      final adminDoc =
          await _firestore.collection('user').doc(adminUser.uid).get();
      // ignore: avoid_print
      print('Admin document exists: ${adminDoc.exists}');
      // ignore: avoid_print
      print('Admin document data: ${adminDoc.data()}');
      if (!adminDoc.exists) {
        throw 'Data admin tidak ditemukan';
      }
      final adminData = adminDoc.data()!;
      // ignore: avoid_print
      print('Admin email: ${adminData['email']}');
      // ignore: avoid_print
      print('Admin password exists: ${adminData.containsKey('password')}');
      final adminEmail = adminData['email'] as String;
      final adminPassword = adminData['password'] as String;

      // ignore: avoid_print
      print('Creating new user with email: $email');
      // Buat user baru di Authentication
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid;
      // ignore: avoid_print
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
      // ignore: avoid_print
      print('User data saved to Firestore');

      // ignore: avoid_print
      print('Attempting to log back in as admin - Email: $adminEmail');
      // Login kembali sebagai admin
      await _auth.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );
      // ignore: avoid_print
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
      // ignore: avoid_print
      print('Detailed error during user creation: $e');
      if (e is FirebaseAuthException) {
        // ignore: avoid_print
        print('Firebase Auth Error Code: ${e.code}');
        // ignore: avoid_print
        print('Firebase Auth Error Message: ${e.message}');
      }

      // Jika terjadi error, coba login ulang sebagai admin
      try {
        // ignore: avoid_print
        print('Attempting to recover admin session...');
        final adminDoc = await _firestore
            .collection('user')
            .where('role', isEqualTo: 'admin')
            .limit(1)
            .get();

        // ignore: avoid_print
        print('Found admin documents: ${adminDoc.docs.length}');
        if (adminDoc.docs.isNotEmpty) {
          final adminData = adminDoc.docs.first.data();
          // ignore: avoid_print
          print('Retrieved admin data: ${adminData.toString()}');
          // ignore: avoid_print
          print('Admin email from recovery: ${adminData['email']}');
          // ignore: avoid_print
          print(
              'Admin password exists in recovery: ${adminData.containsKey('password')}');

          await _auth.signInWithEmailAndPassword(
            email: adminData['email'],
            password: adminData['password'],
          );
          // ignore: avoid_print
          print('Successfully recovered admin session');
        }
      } catch (loginError) {
        // ignore: avoid_print
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
        decoration: const BoxDecoration(
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
          title: Text(
            'Tambah Karyawan',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF001F3D),
            ),
          ),
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
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          prefixIcon:
                              const Icon(Icons.work, color: Color(0xFF001F3D)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            value: selectedPosition,
                            isDense: true,
                            isExpanded: true,
                            iconStyleData: const IconStyleData(
                              icon: Icon(Icons.arrow_drop_down,
                                  color: Color(0xFF001F3D)),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 16,
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
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF001F3D),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF001F3D),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Semua field harus diisi',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
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

                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: Text(
                'Simpan',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    IconData? icon;

    // Tentukan ikon berdasarkan label
    switch (label.toLowerCase()) {
      case 'nama':
        icon = Icons.person;
        break;
      case 'email':
        icon = Icons.email;
        break;
      case 'password':
        icon = Icons.lock;
        break;
      default:
        icon = Icons.text_fields;
    }

    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.black,
        ),
        prefixIcon: Icon(icon, color: Color(0xFF001F3D)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
}

class AbsensiPieChart extends StatefulWidget {
  const AbsensiPieChart({super.key});

  @override
  State<AbsensiPieChart> createState() => _AbsensiPieChartState();
}

class _AbsensiPieChartState extends State<AbsensiPieChart> {
  DateTime selectedDate = DateTime.now();

  Future<Map<String, double>> fetchAbsensiData() async {
    final firestore = FirebaseFirestore.instance;

    // Get start and end of selected month
    final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final endOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);

    // Get all absensi data
    final hadirSnapshot = await firestore.collection('absensi').get();
    // Filter on client side
    final filteredHadir = hadirSnapshot.docs.where((doc) {
      final data = doc.data();
      if (data['tanggal'] == null) return false;
      final tanggal = DateFormat('yyyy-MM-dd').parse(data['tanggal'] as String);
      return tanggal.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          tanggal.isBefore(endOfMonth.add(const Duration(days: 1)));
    });
    final double jumlahHadir = filteredHadir.length.toDouble();

    // Get all pengajuan data
    final pengajuanSnapshot = await firestore.collection('pengajuan').get();

    // Filter izin on client side
    final filteredIzin = pengajuanSnapshot.docs.where((doc) {
      final data = doc.data();
      if (data['jenis'] != 'izin' ||
          data['status'] != 'Disetujui' ||
          // ignore: curly_braces_in_flow_control_structures
          data['tanggal'] == null) return false;
      final tanggal = (data['tanggal'] as Timestamp).toDate();
      return tanggal.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          tanggal.isBefore(endOfMonth.add(const Duration(days: 1)));
    });
    final double jumlahIzin = filteredIzin.length.toDouble();

    // Filter cuti on client side
    final filteredCuti = pengajuanSnapshot.docs.where((doc) {
      final data = doc.data();
      if (data['jenis'] != 'cuti' ||
          data['status'] != 'Disetujui' ||
          data['tanggal'] == null) return false;
      final tanggal = (data['tanggal'] as Timestamp).toDate();
      return tanggal.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          tanggal.isBefore(endOfMonth.add(const Duration(days: 1)));
    });
    final double jumlahCuti = filteredCuti.length.toDouble();

    return {
      'Hadir': jumlahHadir,
      'Izin': jumlahIzin,
      'Cuti': jumlahCuti,
    };
  }

  void _showMonthYearPicker() {
    List<String> months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    List<int> years = [
      DateTime.now().year - 4,
      DateTime.now().year - 3,
      DateTime.now().year - 2,
      DateTime.now().year - 1,
      DateTime.now().year,
    ];
    String tempMonth = months[selectedDate.month - 1];
    int tempYear = selectedDate.year;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Pilih Bulan dan Tahun',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Bulan',
                    labelStyle: GoogleFonts.poppins(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  value: tempMonth,
                  dropdownColor: Colors.white,
                  items: months.map((String month) {
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Text(
                        month,
                        style: GoogleFonts.poppins(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      tempMonth = newValue;
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Tahun',
                    labelStyle: GoogleFonts.poppins(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  value: tempYear,
                  dropdownColor: Colors.white,
                  items: years.map((int year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(
                        year.toString(),
                        style: GoogleFonts.poppins(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      tempYear = newValue;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF001F3D),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  int monthIndex = months.indexOf(tempMonth) + 1;
                  selectedDate = DateTime(tempYear, monthIndex);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF001F3D),
              ),
              child: Text(
                'Pilih',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
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
        final total = data.values.fold(0.0, (sum, value) => sum + value);

        final absensiData = [
          {
            "label": "Hadir",
            "value": data['Hadir'] ?? 0,
            "color": Colors.green,
            "percentage": total > 0 ? ((data['Hadir'] ?? 0) / total * 100) : 0
          },
          {
            "label": "Terlambat",
            "value": data['Terlambat'] ?? 0,
            "color": Colors.red,
            "percentage":
                total > 0 ? ((data['Terlambat'] ?? 0) / total * 100) : 0
          },
          {
            "label": "Izin",
            "value": data['Izin'] ?? 0,
            "color": const Color.fromARGB(255, 235, 38, 169),
            "percentage": total > 0 ? ((data['Izin'] ?? 0) / total * 100) : 0
          },
          {
            "label": "Cuti",
            "value": data['Cuti'] ?? 0,
            "color": Colors.indigoAccent,
            "percentage": total > 0 ? ((data['Cuti'] ?? 0) / total * 100) : 0
          },
          {
            "label": "Alpha",
            "value": data['Alpha'] ?? 0,
            "color": Colors.orange,
            "percentage": total > 0 ? ((data['Alpha'] ?? 0) / total * 100) : 0
          },
        ];

        return Card(
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  // ----------- TANGGAL & TOMBOL -----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                            .format(selectedDate),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showMonthYearPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF001F3D),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat('MMMM yyyy', 'id_ID')
                                    .format(selectedDate),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down,
                                  color: Colors.white, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),
                  // ----------- CHART & LEGENDA -----------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 4,
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
                                            title:
                                                '${(e['percentage'] as double).toStringAsFixed(1)}%',
                                            titleStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            radius: 40,
                                          ))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
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

                  const SizedBox(height: 30),
                  // ----------- ANGKA STATISTIK -----------
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        children: absensiData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final e = entry.value;
                          final isEven = index % 2 == 0;

                          return Container(
                            width: constraints.maxWidth, // ini yang penting!
                            color: isEven ? Colors.grey.shade100 : Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  e['label'] as String,
                                  style: GoogleFonts.poppins(
                                      fontSize: 12, color: Colors.black),
                                ),
                                Text(
                                  "${(e['value'] as double).toInt()}",
                                  style: GoogleFonts.poppins(
                                      fontSize: 12, color: Colors.black),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ]),
              )
            ]));
      },
    );
  }
}
