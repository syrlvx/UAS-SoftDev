import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purelux/screens/login_screen.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _username = '';
  bool _isLoading = true; // Menunjukkan loading saat data sedang diambil

  @override
  void initState() {
    super.initState();
    _getUsername();
  }

  // Fungsi untuk mengambil username dari Firestore
  Future<void> _getUsername() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('user') // Koleksi pengguna di Firestore
            .doc(user.uid) // Menggunakan UID pengguna sebagai ID dokumen
            .get();

        // Mengecek jika data ditemukan dan memiliki field 'username'
        if (userDoc.exists && userDoc.data() != null) {
          setState(() {
            _username = userDoc['username'] ?? 'Username Tidak Tersedia';
            _isLoading = false;
          });
        } else {
          setState(() {
            _username = 'Username Tidak Tersedia';
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _username = 'Gagal mengambil data';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Akun Saya',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0, // Menghilangkan bayangan pada AppBar
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.white, // Menggunakan warna putih untuk background body
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator()) // Menampilkan loading
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  user != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email: ${user.email}',
                              style: TextStyle(
                                fontFamily: 'Item',
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Username: $_username',
                              style: TextStyle(
                                fontFamily: 'Item',
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'UID: ${user.uid}',
                              style: TextStyle(
                                fontFamily: 'Item',
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blueAccent, Colors.indigo],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(
                                    8), // Menjaga tombol tetap bulat
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _auth.signOut();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.transparent, // Tombol transparan
                                  shadowColor: Colors
                                      .transparent, // Menghilangkan bayangan
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8), // Bentuk bulat
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 32),
                                ),
                                child: Text(
                                  'Logout',
                                  style: TextStyle(
                                    color:
                                        Colors.white, // Warna teks tetap putih
                                    fontFamily: 'Item',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Text(
                            'Tidak ada data akun',
                            style: TextStyle(
                              fontFamily: 'Item',
                              color: Colors.black,
                            ),
                          ),
                        ),
                ],
              ),
      ),
    );
  }
}
