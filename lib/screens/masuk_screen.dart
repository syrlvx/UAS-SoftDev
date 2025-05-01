import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

class MasukScreen extends StatefulWidget {
  @override
  _MasukScreenState createState() => _MasukScreenState();
}

class _MasukScreenState extends State<MasukScreen> {
  String? _location;
  String? _currentDate;
  String? _waktuMasuk;
  String? _waktuKeluar;
  bool _sudahMasuk = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getLocation();
    _getDate();
  }

  void _getDate() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    _currentDate = formatter.format(now);
    _cekStatusAbsen();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled || permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _location = 'Permission ditolak permanen';
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      setState(() {
        _location =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}';
      });
    } catch (e) {
      setState(() {
        _location = 'Gagal mendapatkan lokasi: $e';
      });
    }
  }

  Future<void> _cekStatusAbsen() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || _currentDate == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('user_data')
        .doc(user.uid)
        .collection(_currentDate!);

    final masukDoc = await docRef.doc('masuk').get();
    final keluarDoc = await docRef.doc('keluar').get();

    setState(() {
      if (masukDoc.exists) {
        Timestamp ts = masukDoc['timestamp'];
        _waktuMasuk = DateFormat('HH:mm').format(ts.toDate());
        _sudahMasuk = true;
      }

      if (keluarDoc.exists) {
        Timestamp ts = keluarDoc['timestamp'];
        _waktuKeluar = DateFormat('HH:mm').format(ts.toDate());
        _sudahMasuk =
            false; // Sudah keluar berarti bukan dalam kondisi masuk lagi
      }

      _loading = false;
    });
  }

  Future<void> _handleAbsen() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || _currentDate == null || _location == null) return;

    final now = Timestamp.now();
    final nowFormatted = DateFormat('HH:mm').format(DateTime.now());

    final docRef = FirebaseFirestore.instance
        .collection('user_data')
        .doc(user.uid)
        .collection(_currentDate!);

    if (!_sudahMasuk) {
      await docRef.doc('masuk').set({
        'timestamp': now,
        'location': _location,
      });
      setState(() {
        _waktuMasuk = nowFormatted;
        _waktuKeluar = null;
        _sudahMasuk = true;
      });
    } else {
      await docRef.doc('keluar').set({
        'timestamp': now,
        'location': _location,
      });
      setState(() {
        _waktuKeluar = nowFormatted;
        _sudahMasuk = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Tanggal: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Lokasi: ${_location ?? "Loading..."}',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 20),
                    if (_waktuMasuk != null)
                      Text("Waktu Masuk: $_waktuMasuk",
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                    if (_waktuKeluar != null)
                      Text("Waktu Keluar: $_waktuKeluar",
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                    SizedBox(height: 40),
                    ElevatedButton.icon(
                      icon: Icon(
                        _sudahMasuk ? Icons.logout : Icons.login,
                        color: Colors.white,
                      ),
                      label: Text(
                        _sudahMasuk ? "Keluar" : "Masuk",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      ),
                      onPressed: () async {
                        await _handleAbsen();
                        await _cekStatusAbsen(); // Refresh data setelah absen
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
