import 'package:flutter/material.dart';
import 'dart:async'; // Untuk menggunakan Timer

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Fungsi ini digunakan untuk berpindah ke halaman BottomNavBar setelah timer selesai
  @override
  void initState() {
    super.initState();
    // Menunggu selama 3 detik sebelum pindah ke BottomNavBar
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/bottomNav');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Warna latar belakang splash screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.access_alarm, // Bisa diganti dengan logo aplikasi
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'Selamat Datang!',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
