import 'dart:async';
import 'package:flutter/material.dart';
import 'package:purelux/screens/akun_screen.dart';
import 'package:purelux/screens/izincuti_screen.dart';
import 'package:purelux/screens/notifikasi_screen.dart';
import 'package:purelux/screens/riwayat_screen.dart';
import 'package:purelux/screens/tugas_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  late String _currentTime;
  bool isLoggedIn = false;
  bool hasUnreadNotifications = false;

  String? username;
  String? role;
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _currentTime = _getCurrentTime();
    _startTimer();
    _fetchUserData();
    _checkUnreadNotifications();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;
        final doc =
            await FirebaseFirestore.instance.collection('user').doc(uid).get();
        if (doc.exists) {
          setState(() {
            username = doc['username'];
            role = doc['role'];
            isLoadingUser = false;
          });
        } else {
          print("User document not found.");
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _checkUnreadNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('read', isEqualTo: false)
        .get();

    setState(() {
      hasUnreadNotifications = snapshot.docs.isNotEmpty;
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = _getCurrentTime();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoadingUser
          ? Center(child: CircularProgressIndicator())
          : Stack(
              clipBehavior: Clip.none,
              children: [
                // Background Gradient AppBar
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF001F3D), // Biru navy gelap
                        Color(0xFFFFFFFF), // Putih
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 0, bottom: 150, left: 16, right: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.account_circle,
                                size: 60, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AccountScreen()),
                              );
                            },
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                username ?? 'User',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                role ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Stack(
                            children: [
                              IconButton(
                                icon: Icon(Icons.notifications,
                                    color: Colors.white, size: 30),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            NotificationScreen()),
                                  );
                                  // Check for unread notifications after returning from notification screen
                                  _checkUnreadNotifications();
                                },
                              ),
                              if (hasUnreadNotifications)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      '!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Card yang menimpa AppBar
                Positioned(
                  top: 140,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2), // Warna bayangan
                          blurRadius: 10, // Seberapa kabur bayangannya
                          spreadRadius: 2, // Seberapa besar area bayangannya
                          offset: Offset(
                              0, 2), // Arah bayangan (x, y) → ini ke bawah
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Baris atas: Jam & Tanggal
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time, color: Colors.grey),
                                SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Reguler',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold)),
                                    Text('08:00 - 17:00',
                                        style: TextStyle(color: Colors.black)),
                                    Text('Masuk',
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 127, 157, 195),
                                        )),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Selasa',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                                Text('22 Februari 2022',
                                    style: TextStyle(color: Colors.black)),
                                Text('Pulang',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 127, 157, 195),
                                    )),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Judul tengah
                        Center(
                          child: Text(
                            'Rekap Absensi Bulan Ini',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Statistik absensi
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatBox('HADIR', '0 Hari', Colors.green),
                            _buildStatBox('IZIN', '0 Hari',
                                const Color.fromARGB(255, 243, 33, 33)),
                            _buildStatBox(
                                'SISA CUTI', '12 Hari', Colors.orange),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Menu Grid bawah card
                Padding(
                  padding: EdgeInsets.only(top: 430),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih Fitur:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),
                        GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          children: [
                            _buildMenuItem(
                              Icons.description,
                              'Pengajuan',
                              () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => PengajuanScreen()),
                              ),
                            ),
                            _buildMenuItem(
                              Icons.assignment,
                              'Tugas',
                              () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => TugasScreen()),
                              ),
                            ),
                            _buildMenuItem(
                              Icons.history,
                              'Riwayat',
                              () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => RiwayatScreen()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2, // Bayangan default dari Card
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Warna bayangan
                spreadRadius: 1, // Jarak bayangan dari widget
                blurRadius: 5, // Mengaburkan bayangan
                offset: Offset(0, -1), // Posisi bayangan (horizontal, vertikal)
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Color.fromARGB(255, 127, 157, 195),
              ),
              SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 127, 157, 195),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildStatBox(String title, String count, Color color) {
  return Column(
    children: [
      Text(title,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      SizedBox(height: 4),
      Text(count, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      SizedBox(height: 4),
      Container(height: 4, width: 40, color: color),
    ],
  );
}
