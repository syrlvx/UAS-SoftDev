import 'package:flutter/material.dart';
import 'dart:async';
import 'package:purelux/screens/login_screen.dart'; // Untuk menggunakan Timer

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Fungsi ini digunakan untuk berpindah ke halaman BottomNavBar setelah timer selesai
  @override
  void initState() {
    super.initState();
    // Menunggu selama 3 detik sebelum pindah ke BottomNavBar
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
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
