import 'package:flutter/material.dart';
import 'package:purelux/screens/home_admin.dart';
import 'package:purelux/screens/data_admin.dart';
import 'package:purelux/screens/pengajuan_admin.dart';
import 'package:purelux/screens/tugas_admin.dart';

class BottomNavBarAdmin extends StatefulWidget {
  const BottomNavBarAdmin({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BottomNavBarAdminState createState() => _BottomNavBarAdminState();
}

class _BottomNavBarAdminState extends State<BottomNavBarAdmin> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeAdminScreen(),
    PengajuanAdminScreen(),
    const TugasAdminScreen(),
    const DataAdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Material(
        elevation: 0,
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 1,
              color: const Color(0xFFB0BEC5),
            ),
            SizedBox(
              height: 80,
              child: BottomNavigationBar(
                elevation: 0,
                backgroundColor: Colors.white,
                currentIndex: _currentIndex,
                selectedItemColor: const Color.fromARGB(255, 127, 157, 195),
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
            ),
          ],
        ),
      ),
    );
  }
}
