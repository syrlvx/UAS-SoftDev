import 'package:flutter/material.dart';
import 'package:purelux/screens/masuk_screen.dart';
import 'package:purelux/screens/keluar_screen.dart';

class AbsensiScreen extends StatefulWidget {
  @override
  _AbsensiScreenState createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Absensi Karyawan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Tengah-tengah
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Menambahkan dua tombol untuk absen masuk dan absen keluar
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MasukScreen(), // Pindah ke screen masuk
                  ),
                );
              },
              child: _buildMenuCard(
                Icons.login,
                'Absen Masuk',
                Colors.green[50]!,
                Colors.green,
              ),
            ),
            SizedBox(height: 20), // Spacer
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        KeluarScreen(), // Pindah ke screen keluar
                  ),
                );
              },
              child: _buildMenuCard(
                Icons.exit_to_app,
                'Absen Keluar',
                Colors.red[50]!,
                Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membuat card menu yang digunakan berulang
  Widget _buildMenuCard(
      IconData icon, String label, Color backgroundColor, Color iconColor) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: backgroundColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
