import 'dart:async';
import 'package:flutter/material.dart';
import 'package:purelux/screens/akun_screen.dart';
import 'package:purelux/screens/izincuti_screen.dart';
import 'package:purelux/screens/notifikasi_screen.dart';
import 'package:purelux/screens/riwayat_screen.dart';
import 'package:purelux/screens/tugas_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
  String? photoUrl;
  bool isLoadingUser = true;
  int hadirBulanIni = 0;
  int izinBulanIni = 0;

  @override
  void initState() {
    super.initState();
    _currentTime = _getCurrentTime();
    _startTimer();
    _fetchUserData();
    _checkUnreadNotifications();
    _countHadirThisMonth();
    _countIzinThisMonth();
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
            photoUrl = doc.data()?['foto'];
            isLoadingUser = false;
          });
        } else {
          // ignore: avoid_print
          print("User document not found.");
        }
      }
    } catch (e) {
      // ignore: avoid_print
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

  Future<void> _countHadirThisMonth() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final now = DateTime.now();
      final firstDay = DateTime(now.year, now.month, 1);
      final lastDay = DateTime(now.year, now.month + 1, 0);

      // Format tanggal untuk filter
      final formattedFirstDay = DateFormat('yyyy-MM-dd').format(firstDay);
      final formattedLastDay = DateFormat('yyyy-MM-dd').format(lastDay);

      // Query collection absensi hanya dengan user_id
      final snapshot = await FirebaseFirestore.instance
          .collection('absensi')
          .where('user_id', isEqualTo: user.uid)
          .get();

      // Filter dan hitung di client side
      int hadirCount = 0;
      for (var doc in snapshot.docs) {
        final tanggal = doc['tanggal'] as String;

        // Check if tanggal is within current month
        if (tanggal.compareTo(formattedFirstDay) >= 0 &&
            tanggal.compareTo(formattedLastDay) <= 0) {
          // Hitung semua hari kehadiran
          hadirCount++;
        }
      }

      setState(() {
        hadirBulanIni = hadirCount;
      });
    } catch (e) {
      print('Error menghitung hadir bulan ini: $e');
    }
  }

  Future<void> _countIzinThisMonth() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final uid = user.uid;
      final now = DateTime.now();
      final firstDay = DateTime(now.year, now.month, 1);
      final lastDay = DateTime(now.year, now.month + 1, 0);
      final snapshot = await FirebaseFirestore.instance
          .collection('pengajuan')
          .where('userId', isEqualTo: uid)
          .where('jenis', isEqualTo: 'izin')
          .where('tanggal',
              isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay))
          .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(lastDay))
          .where('status', isEqualTo: 'Disetujui')
          .get();
      setState(() {
        izinBulanIni = snapshot.docs.length;
      });
    } catch (e) {
      print('Error menghitung izin bulan ini: $e');
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    // ignore: prefer_const_constructors
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
    final now = DateTime.now();
    final hari = DateFormat('EEEE', 'id_ID').format(now);
    final tanggal = DateFormat('d MMMM yyyy', 'id_ID').format(now);
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoadingUser
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              clipBehavior: Clip.none,
              children: [
                // Background Gradient AppBar
                Container(
                  height: 300,
                  decoration: const BoxDecoration(
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
                      padding: const EdgeInsets.only(
                          top: 0, bottom: 150, left: 16, right: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: photoUrl != null && photoUrl!.isNotEmpty
                                ? CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(photoUrl!),
                                    backgroundColor: Colors.white,
                                  )
                                : const Icon(Icons.account_circle,
                                    size: 60, color: Colors.white),
                            iconSize: 60,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AccountScreen()),
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                username ?? 'User',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                role ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications,
                                    color: Colors.white, size: 30),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const NotificationScreen()),
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
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: const Text(
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2), // Warna bayangan
                          blurRadius: 10, // Seberapa kabur bayangannya
                          spreadRadius: 2, // Seberapa besar area bayangannya
                          offset: const Offset(
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
                                Text(hari,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                                Text(tanggal,
                                    style: TextStyle(color: Colors.black)),
                                Text('Pulang',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 127, 157, 195),
                                    )),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Judul tengah
                        const Center(
                          child: Text(
                            'Rekap Absensi Bulan Ini',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Statistik absensi
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatBox(
                                'HADIR', '$hadirBulanIni Hari', Colors.green),
                            _buildStatBox('IZIN', '$izinBulanIni Hari',
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
                  padding: const EdgeInsets.only(top: 430),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pilih Fitur:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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
                                    builder: (_) => const TugasScreen()),
                              ),
                            ),
                            _buildMenuItem(
                              Icons.history,
                              'Riwayat',
                              () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const RiwayatScreen()),
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
                offset: const Offset(
                    0, -1), // Posisi bayangan (horizontal, vertikal)
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: const Color.fromARGB(255, 127, 157, 195),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
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
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(count, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Container(height: 4, width: 40, color: color),
    ],
  );
}
