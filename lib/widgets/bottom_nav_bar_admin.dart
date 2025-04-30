import 'package:flutter/material.dart';
import 'package:purelux/screens/absensi_admin.dart';
import 'package:purelux/screens/data_admin.dart';
import 'package:purelux/screens/pengajuan_admin.dart';
import 'package:purelux/screens/tugas_screen.dart';

class BottomNavBarAdmin extends StatefulWidget {
  @override
  _BottomNavBarAdminState createState() => _BottomNavBarAdminState();
}

class _BottomNavBarAdminState extends State<BottomNavBarAdmin> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    AbsensiAdminScreen(),
    PengajuanAdminScreen(),
    TugasScreen(),
    DataAdminScreen(),
  ];

  final List<String> _titles = [
    'Absensi',
    'Pengajuan',
    'Tugas',
    'Data Karyawan',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Absensi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_copy),
            label: 'Pengajuan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Karyawan',
          ),
        ],
      ),
    );
  }
}
