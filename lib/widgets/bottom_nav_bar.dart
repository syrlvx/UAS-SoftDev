import 'package:flutter/material.dart';
import 'package:purelux/screens/data_karyawan.dart';
import 'package:purelux/screens/home_screen.dart';
import 'package:purelux/screens/masuk_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(), // Panggil HomeScreen dari file home_screen.dart
    MasukScreen(), // Panggil AbsensiScreen dari file absensi_screen.dart
    const DataKaryawanScreen(), // Panggil DataAbsensiScreen dari file data_absensi_screen.dart
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // supaya kelihatan jelas saat preview
      body: _pages[_currentIndex], // Halaman akan berubah sesuai _currentIndex
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipPath(
            clipper: TopCurveClipper(),
            child: Container(
              height: 80,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  navItem(Icons.home, "Beranda", 0),
                  const SizedBox(width: 60), // space tengah
                  navItem(Icons.people, "Data Absensi", 2),
                ],
              ),
            ),
          ),
          // Menambahkan garis di atas bottom navigation bar
          Positioned(
            child: Container(
              height: 1,
              color: const Color(0xFFB0BEC5), // Warna garis
            ),
          ),
          Positioned(
            top: -30,
            left: MediaQuery.of(context).size.width / 2 - 35,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = 1; // Pindah ke halaman Absensi
                });
              },
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _currentIndex == 1
                              // ignore: deprecated_member_use
                              ? Colors.blue.withOpacity(
                                  0.5) // Efek bayangan biru saat dipencet
                              : Colors.black
                                  // ignore: deprecated_member_use
                                  .withOpacity(0.4), // Bayangan default
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.access_time_filled,
                      color:
                          Color.fromARGB(255, 127, 157, 195), // Ikon tetap biru
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Absensi",
                    style: TextStyle(
                      color: _currentIndex == 1
                          ? const Color.fromARGB(255, 127, 157, 195)
                          : Colors.grey, // Teks jadi biru saat dipencet
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget navItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index; // Update index saat item ditekan
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: _currentIndex == index
                  ? const Color.fromARGB(255, 127, 157, 195)
                  : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: _currentIndex == index
                  ? const Color.fromARGB(255, 127, 157, 195)
                  : Colors.grey,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double radius = 35.0;
    final double centerX = size.width / 2;

    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(centerX - radius - 15, 0);

    // Lekukan ke ATAS
    path.quadraticBezierTo(centerX - radius, 0, centerX - radius, -20);
    path.arcToPoint(
      Offset(centerX + radius, -20),
      radius: const Radius.circular(radius),
      clockwise: false,
    );
    path.quadraticBezierTo(centerX + radius, 0, centerX + radius + 15, 0);

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
