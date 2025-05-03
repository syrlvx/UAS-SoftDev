import 'package:flutter/material.dart';
import 'package:purelux/screens/home_admin.dart';
import 'package:purelux/screens/data_admin.dart';
import 'package:purelux/screens/pengajuan_admin.dart';
import 'package:purelux/screens/tugas_admin.dart';

class BottomNavBarAdmin extends StatefulWidget {
  @override
  _BottomNavBarAdminState createState() => _BottomNavBarAdminState();
}

class _BottomNavBarAdminState extends State<BottomNavBarAdmin> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeAdminScreen(),
    PengajuanAdminScreen(),
    TugasAdminScreen(),
    DataAdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Material(
        elevation: 0, // Menghapus bayangan navbar
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Agar column tidak meluas
          children: [
            Container(
              height: 1, // Tinggi garis
              color: Color(0xFFB0BEC5), // Warna abu-abu untuk garis
            ),
            BottomNavigationBar(
              elevation: 0, // Menghapus bayangan di navbar
              backgroundColor: Colors.white,
              currentIndex: _currentIndex,
              selectedItemColor: Color(0xFF001F3D),
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 14,
              unselectedFontSize: 12,
              iconSize: 28,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.file_copy),
                  label: 'Pengajuan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment),
                  label: 'Tugas',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group),
                  label: 'Karyawan',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
