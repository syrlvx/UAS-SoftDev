import 'dart:async';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  late String _currentTime;
  bool isLoggedIn = false; // Status login

  @override
  void initState() {
    super.initState();
    _currentTime = _getCurrentTime(); // Set initial time
    _startTimer(); // Start the timer to update time every second
  }

  // Fungsi untuk mendapatkan waktu sekarang
  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute}:${now.second}';
  }

  // Fungsi untuk memulai timer yang memperbarui waktu setiap detik
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = _getCurrentTime(); // Update the time
      });
    });
  }

  // Fungsi untuk toggle login/logout
  void _toggleLogin() {
    setState(() {
      isLoggedIn = !isLoggedIn;
    });

    // Tampilkan pesan snack bar saat login/logout
    if (isLoggedIn) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Berhasil login!')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Berhasil logout!')));
    }
  }

  // Fungsi untuk berpindah ke layar login
  void _goToLoginScreen() {
    Navigator.pushNamed(
        context, '/login'); // Ganti '/login' dengan nama rute login kamu
  }

  @override
  void dispose() {
    _timer
        .cancel(); // Jangan lupa untuk membatalkan timer ketika widget dihapus
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            isLoggedIn ? Icons.exit_to_app : Icons.account_circle,
            size: 40, // Ukuran ikon lebih besar
          ),
          onPressed: _goToLoginScreen, // Navigasi ke layar login
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 8),
            Text('Absensi Karyawan'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section: Name, Position, Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.business, size: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Sherly Olivia',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text('Junior Developer'),
                    SizedBox(height: 8),
                    Text('Time: $_currentTime'),
                  ],
                ),
              ],
            ),
            Divider(),

            // Absensi, Izin/Cuti, Tugas Buttons
            SizedBox(height: 20),
            Text(
              'Pilih Fitur:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Grid Menu for Fitur
            Expanded(
              child: GridView.count(
                crossAxisCount: 3, // 3 Kolom
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: <Widget>[
                  // Button for Absensi
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/absensi');
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blue[50],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.access_alarm,
                                size: 40, color: Colors.blue),
                            SizedBox(height: 10),
                            Text(
                              'Absensi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Button for Izin / Cuti
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/izin-cuti');
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.green[50],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today,
                                size: 40, color: Colors.green),
                            SizedBox(height: 10),
                            Text(
                              'Izin / Cuti',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Button for Tugas
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/tugas');
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.orange[50],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment,
                                size: 40, color: Colors.orange),
                            SizedBox(height: 10),
                            Text(
                              'Tugas',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
