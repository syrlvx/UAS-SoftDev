import 'package:flutter/material.dart';
import 'package:purelux/screens/izin_screen.dart';
import 'package:purelux/screens/cuti_screen.dart';
import 'package:purelux/widgets/bottom_nav_bar.dart'; // Import HomeScreen jika ada

class PengajuanScreen extends StatefulWidget {
  @override
  _PengajuanScreenState createState() => _PengajuanScreenState();
}

class _PengajuanScreenState extends State<PengajuanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // background putih
      appBar: AppBar(
        backgroundColor: Colors.blue, // background biru untuk app bar
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Colors.white), // Tombol back warna putih
          onPressed: () {
            // Ganti HomeScreen() dengan screen utama aplikasi Anda
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      BottomNavBar()), // Sesuaikan dengan screen utama
            );
          },
        ),
        title: Text(
          'Pengajuan', // Teks Pengajuan
          style: TextStyle(
            color: Colors.white, // Teks putih
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IzinScreen(),
                  ),
                );
              },
              child: _buildMenuCard(
                Icons.report_problem,
                'Izin',
                Colors.blue[50]!,
                Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CutiScreen(),
                  ),
                );
              },
              child: _buildMenuCard(
                Icons.beach_access,
                'Cuti',
                Colors.orange[50]!,
                Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
