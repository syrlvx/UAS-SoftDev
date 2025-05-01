import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class MasukScreen extends StatefulWidget {
  @override
  _MasukScreenState createState() => _MasukScreenState();
}

class _MasukScreenState extends State<MasukScreen> {
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
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
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
      appBar: AppBar(title: Text("Masuk Screen")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentDate ?? "Loading date...",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              _location ?? "Getting location...",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Fungsi login dan simpan data
                _saveDataToFirebase();
                // Kamu bisa menambahkan fungsi login di sini
              },
              child: Text("Masuk"),
            ),
          ],
        ),
      ),
    );
  }
}
