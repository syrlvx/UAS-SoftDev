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
        elevation: 0, // Ini yang bikin ga ada bayangan/border
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 1), // Padding untuk navbar
          child: Column(
            mainAxisSize: MainAxisSize.min, // Agar column tidak meluas
            children: [
              Container(
                height: 1,
                color: Color(0xFFB0BEC5), // Garis abu-abu di atas navbar
              ),
              BottomNavigationBar(
                elevation: 0, // Tambahin ini juga!
                backgroundColor: Colors.white,
                currentIndex: _currentIndex,
                selectedItemColor: Colors.blue,
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
      ),
    );
  }
}
