import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataKaryawanScreen extends StatefulWidget {
  const DataKaryawanScreen({super.key});

  @override
  State<DataKaryawanScreen> createState() => _DataKaryawanScreenState();
}

class _DataKaryawanScreenState extends State<DataKaryawanScreen> {
  String selectedMonth = 'Apr - 2022';
  final List<String> months = ['Mar - 2022', 'Apr - 2022', 'May - 2022'];

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
                  _buildProfileAkun(), // ✅ Tambahkan bagian profil
                  const SizedBox(height: 24),
                  _buildRekapAbsensi(),
                  _buildKinerjaKaryawan(), // ✅ Tambahkan bagian kinerja
                  const SizedBox(height: 20),
                  _buildMenuItem(Icons.calendar_today, 'Rekap Absensi',
                      'Detail rekapitulasi absensimu'),
                  _buildMenuItem(Icons.description, 'Rekap Pengajuan',
                      'Daftar pengajuan izin & cuti kamu'),
                  _buildMenuItem(Icons.access_time_filled, 'Rekap Lembur',
                      'Laporan rekapitulasi lemburmu'),
                  _buildMenuItem(Icons.task, 'Rekap Tugas',
                      'Tugas-tugas yang diberikan kepadamu'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRekapAbsensi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul + Dropdown
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white, // Warna dropdown
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: Colors.grey.shade300), // Biar ada batas
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor:
                      Colors.white, // Pastikan dropdown list juga putih
                  value: selectedMonth,
                  items: months.map((month) {
                    return DropdownMenuItem(
                      value: month,
                      child: Text(
                        month,
                        style: GoogleFonts.poppins(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value!;
                    });
                  },
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Card isi rekapnya
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3 di atas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAbsensiCard('Hadir', '8 Hari', Colors.green),
                  _buildAbsensiCard('Alpa', '1 Hari', Colors.red),
                  _buildAbsensiCard('Lembur', '6 kali', Colors.pink),
                ],
              ),
              const SizedBox(height: 12),

              // 2 di bawah
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAbsensiCard('Izin', '8 Hari', Colors.blue),
                  _buildAbsensiCard('Cuti', '1 Hari', Colors.orange),
                ],
              ),
              const SizedBox(height: 12),

              // 3 terakhir
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAbsensiCard('Terlambat', '1 Hari', Colors.amber),
                  _buildAbsensiCard('Pulang Cepat', '8 Hari', Colors.lightBlue),
                  _buildAbsensiCard(
                      'Tidak Absen Pulang', '1 Hari', Colors.purpleAccent),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAbsensiCard(String title, String value, Color color) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.50),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 4,
              width: 60, // Panjang garis bawah
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 28, color: Colors.black),
        title: Text(title,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.black)),
        subtitle:
            Text(subtitle, style: GoogleFonts.poppins(color: Colors.black54)),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
        onTap: () {
          // Handle tap event
        },
      ),
    );
  }
}

Widget _buildKinerjaKaryawan() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 20),
      Text(
        'Kinerja Karyawan',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
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
            _buildKinerjaItem('Tugas Diselesaikan', '12 Tugas'),
            _buildKinerjaItem('Lembur Disetujui', '5 Lembur'),
            _buildKinerjaItem('Pengajuan Disetujui', '3 Izin, 1 Cuti'),
            _buildKinerjaItem('Terlambat Masuk', '2 Kali'),
            _buildKinerjaItem('Pulang Sebelum Waktu', '1 Kali'),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Skor Kinerja Bulanan',
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                Text('85/100',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700])),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.85,
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
}

Widget _buildKinerjaItem(String title, String result) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
        ),
        Text(
          result,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: Colors.blueGrey,
          ),
        ),
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
              backgroundColor: Colors.blueAccent,
              child: Text(
                username.trim().isNotEmpty
                    ? username
                        .trim()
                        .split(' ')
                        .map((e) => e.isNotEmpty ? e[0] : '')
                        .take(2)
                        .join()
                        .toUpperCase()
                    : '?',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Initials in white
                ),
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
