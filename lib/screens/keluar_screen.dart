import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class KeluarScreen extends StatefulWidget {
  @override
  _KeluarScreenState createState() => _KeluarScreenState();
}

class _KeluarScreenState extends State<KeluarScreen> {
  String? _location;
  String? _currentDate;

  @override
  void initState() {
    super.initState();
    _getLocation();
    _getDate();
  }

  // Mendapatkan lokasi real-time
  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _location = "Lokasi tidak tersedia";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        setState(() {
          _location = "Izin lokasi ditolak";
        });
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _location = 'Lat: ${position.latitude}, Long: ${position.longitude}';
    });
  }

  // Mendapatkan tanggal sekarang
  void _getDate() {
    final now = DateTime.now();
    final formatter = DateFormat('dd MMMM yyyy, HH:mm');
    setState(() {
      _currentDate = formatter.format(now);
    });
  }

  // Fungsi untuk menyimpan data ke Firebase
  Future<void> _saveDataToFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('user_data').add({
        'user_id': user.uid,
        'date': _currentDate,
        'location': _location,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Keluar Screen")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tanggal dan Waktu: ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              _currentDate ?? "Memuat tanggal...",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Lokasi: ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              _location ?? "Memuat lokasi...",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Fungsi simpan data ke Firebase
                _saveDataToFirebase();
              },
              child: Text("Keluar"),
            ),
          ],
        ),
      ),
    );
  }
}
