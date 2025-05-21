import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purelux/screens/rekap_absensi.dart';
import 'package:purelux/screens/rekap_pengajuan.dart';
import 'package:purelux/screens/rekap_tugas.dart';
import 'package:month_year_picker/month_year_picker.dart';

class DataKaryawanScreen extends StatefulWidget {
  const DataKaryawanScreen({super.key});

  @override
  State<DataKaryawanScreen> createState() => _DataKaryawanScreenState();
}

class _DataKaryawanScreenState extends State<DataKaryawanScreen> {
  String? username;
  String? role;
  String? photoUrl;
  bool isLoadingUser = true;

  // Menghapus month picker yang bermasalah
  DateTime selectedDate = DateTime.now();
  String _getMonthName(int month) {
    const monthNames = [
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
    return monthNames[month - 1];
  }

  late String selectedMonthYear;

  // Daftar tahun yang dapat dipilih
  final List<int> years = [2021, 2022, 2023, 2024, 2025];
  late int selectedYear;

  // Daftar bulan yang dapat dipilih
  final List<String> months = [
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
  late String selectedMonth;

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;
        final doc =
            await FirebaseFirestore.instance.collection('user').doc(uid).get();
        if (doc.exists) {
          setState(() {
            username = doc['username'];
            role = doc['role'];
            photoUrl = doc.data()?['foto'];
            isLoadingUser = false;
          });
        } else {
          // ignore: avoid_print
          print("User document not found.");
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching user data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    selectedMonth = months[selectedDate.month - 1];
    selectedYear = selectedDate.year;
    selectedMonthYear = '$selectedMonth $selectedYear';
  }

  Future<void> _showMonthYearPickerDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Warna latar dialog putih
          title: Text(
            'Pilih Bulan dan Tahun',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Teks warna hitam
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pilih Bulan
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Bulan',
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  dropdownColor: Colors.white, // Dropdown list putih
                  value: selectedMonth,
                  items: months.map((String month) {
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Text(
                        month,
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedMonth = newValue;
                      });
                    }
                  },
                ),

                const SizedBox(height: 20), // Jarak antar dropdown

                // Pilih Tahun
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Tahun',
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  dropdownColor: Colors.white, // Dropdown list putih
                  value: selectedYear,
                  items: years.map((int year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(
                        year.toString(),
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedYear = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedMonthYear = '$selectedMonth $selectedYear';
                  int monthIndex = months.indexOf(selectedMonth) + 1;
                  selectedDate = DateTime(selectedYear, monthIndex);
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF001F3D), // Dark Navy Blue
              Color(0xFFFFFFFF), // White
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileAkun(),
                  const SizedBox(height: 24),
                  _buildRekapAbsensi(),
                  _buildKinerjaKaryawan(),
                  const SizedBox(height: 20),
                  _buildMenuItem(Icons.calendar_today, 'Rekap Absensi',
                      'Detail rekapitulasi absensi', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RekapAbsensiScreen()),
                    );
                  }),
                  _buildMenuItem(
                    Icons.description,
                    'Rekap Pengajuan',
                    'Daftar pengajuan izin & cuti',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RekapPengajuanScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    Icons.task,
                    'Rekap Tugas',
                    'Tugas-tugas yang diberikan',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RekapTugasScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRekapAbsensi() {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder(
      future: Future.wait([
        // Ambil semua dokumen absensi user, tanpa filter status
        FirebaseFirestore.instance
            .collection('absensi')
            .where('user_id', isEqualTo: user?.uid)
            .get(),
        // Ambil pengajuan izin dan cuti user
        FirebaseFirestore.instance
            .collection('pengajuan')
            .where('userId', isEqualTo: user?.uid)
            .get(),
      ]),
      builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Data tidak ditemukan'));
        }

        final hadirCount = snapshot.data![0].docs.length;
        final pengajuanDocs = snapshot.data![1].docs;

        int izin = pengajuanDocs.where((d) => d['jenis'] == 'izin').length;
        int cuti = pengajuanDocs.where((d) => d['jenis'] == 'cuti').length;

        // Debug print
        print('Debug hadirCount: $hadirCount');
        print('Debug izin: $izin');
        print('Debug cuti: $cuti');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul + Dropdown bulan - DIGANTI DENGAN IMPLEMENTASI BARU
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rekap Absensi',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showMonthYearPickerDialog(),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedMonthYear,
                          style: GoogleFonts.poppins(color: Colors.black),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down,
                            color: Colors.black, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildAbsensiCard('$hadirCount Hari', 'Hadir', Colors.green),
                  _buildAbsensiCard('1 Hari', 'Terlambat', Colors.orange),
                  _buildAbsensiCard('1 Hari', 'Alpha', Colors.orange),
                  _buildAbsensiCard('$izin Hari', 'Izin', Colors.blue),
                  _buildAbsensiCard('$cuti Hari', 'Cuti', Colors.deepOrange),
                ],
              ),
            ),

            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildAbsensiCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi yang sudah ada di code sebelumny
}

Widget _buildAbsensiCard(String label, String value, Color color) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 4,
          width: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    ),
  );
}

Widget _buildMenuItem(
  IconData icon,
  String title,
  String subtitle,
  VoidCallback onTap,
) {
  return Card(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: ListTile(
      leading: Icon(
        icon,
        color: Color.fromARGB(255, 127, 157, 195), // Warna logo di sini
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    ),
  );
}

Widget _buildKinerjaKaryawan() {
  final user = FirebaseAuth.instance.currentUser;

  return FutureBuilder(
    future: Future.wait([
      FirebaseFirestore.instance
          .collection('tugas')
          .where('karyawanUid', isEqualTo: user?.uid)
          .get(),
      FirebaseFirestore.instance
          .collection('pengajuan')
          .where('userId', isEqualTo: user?.uid)
          .get(),
    ]),
    builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return const Center(child: Text('Terjadi kesalahan'));
      }

      final tugasDocs = snapshot.data![0].docs;
      final pengajuanDocs = snapshot.data![1].docs;

      int tugasSelesai = 0;
      int tugasTerlambat = 0;

      for (var doc in tugasDocs) {
        final status = doc['status']?.toString().toLowerCase();
        if (status == 'selesai') {
          tugasSelesai++;
        } else if (status == 'terlambat') {
          tugasTerlambat++;
        }
      }

      int totalTugas = tugasSelesai + tugasTerlambat;

      int cutiDisetujui = 0;
      int pengajuanDitolak = 0;
      int izinDitolak = 0;
      int cutiDitolak = 0;

      for (var doc in pengajuanDocs) {
        final status = doc['status']?.toString().toLowerCase();
        final jenis = doc['jenis']?.toString().toLowerCase();
        if (status == 'disetujui' && jenis == 'cuti') {
          cutiDisetujui++;
        }
        if (status == 'ditolak') {
          pengajuanDitolak++;
          if (jenis == 'izin') izinDitolak++;
          if (jenis == 'cuti') cutiDitolak++;
        }
      }

      // ————— Perhitungan Skor —————
      const maxCutiNormal = 2;
      const maxDitolakNormal = 2;

      double skorTugasSelesai =
          totalTugas > 0 ? (tugasSelesai / totalTugas) * 40 : 0;
      double skorTugasTerlambat =
          totalTugas > 0 ? (1 - (tugasTerlambat / totalTugas)) * 20 : 20;
      double skorCuti = (1 - (cutiDisetujui / maxCutiNormal)).clamp(0, 1) * 20;
      double skorDitolak =
          (1 - (pengajuanDitolak / maxDitolakNormal)).clamp(0, 1) * 20;

      double totalSkor =
          skorTugasSelesai + skorTugasTerlambat + skorCuti + skorDitolak;
      int finalSkor = totalSkor.round();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Kinerja Karyawan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildKinerjaItem('Cuti Disetujui', '$cutiDisetujui Cuti'),
                _buildKinerjaItem('Pengajuan Ditolak',
                    '$izinDitolak Izin, $cutiDitolak Cuti'),
                _buildKinerjaItem('Tugas Selesai', '$tugasSelesai Tugas'),
                _buildKinerjaItem('Tugas Terlambat', '$tugasTerlambat Tugas'),

                const Divider(height: 24),

                /// ————— Skor Kinerja —————
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Skor Kinerja Bulanan',
                        style: GoogleFonts.poppins(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    Text('$finalSkor/100',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700])),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: finalSkor / 100,
                  backgroundColor: Colors.grey[300],
                  color: Colors.green,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

/// Helper untuk men-generate satu baris info kinerja
Widget _buildKinerjaItem(String title, String result) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
        Text(result,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500, color: Colors.blueGrey)),
      ],
    ),
  );
}

Widget _buildProfileAkun() {
  final user = FirebaseAuth.instance.currentUser;

  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance.collection('user').doc(user?.uid).get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || !snapshot.data!.exists) {
        return const Text('Data pengguna tidak ditemukan');
      }

      var data = snapshot.data!.data() as Map<String, dynamic>;
      String username = data['username'] ?? 'Nama tidak tersedia';
      String role = data['role'] ?? '-';
      String photo = data['foto'] ?? '-';

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.grey[200],
              backgroundImage: NetworkImage(
                photo,
              ),
            ),
            SizedBox(width: 16), // Adds spacing between the avatar and text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black, // Username color is black
                  ),
                ),
                Text(
                  role,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black, // Role color is black
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
