import 'package:flutter/material.dart';
import 'package:purelux/screens/data_karyawan.dart';
import 'package:purelux/screens/home_screen.dart';
import 'package:purelux/screens/notifikasi_screen.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    NotifikasiScreen(),
    DataKaryawanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Menampilkan halaman berdasarkan index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        selectedItemColor: Color(0xFF999999),
        unselectedItemColor: Color(0xFF999999),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Data Karyawan',
          ),
        ],
      ),
    );
  }
}
