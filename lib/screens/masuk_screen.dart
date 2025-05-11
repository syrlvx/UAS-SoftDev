import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:purelux/screens/PetaScreen.dart';
import 'dart:async';

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
  bool _sudahKeluar = false;
  bool _loading = true;
  Position? _currentPosition; // Diperlukan untuk akses lokasi

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _getLocation();
      _getDate();
    } catch (e) {
      print('Error initializing data: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  void _getDate() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    _currentDate = formatter.format(now);
    _cekStatusAbsen();
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _location = 'Lokasi tidak aktif';
          _loading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _location = 'Izin lokasi ditolak';
            _loading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _location = 'Izin lokasi ditolak permanen';
          _loading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Mengambil lokasi terlalu lama');
        },
      );

      _currentPosition = position;

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            throw TimeoutException('Mengambil alamat terlalu lama');
          },
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          setState(() {
            _location =
                '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}';
            _loading = false;
          });
        } else {
          setState(() {
            _location = 'Lokasi: ${position.latitude}, ${position.longitude}';
            _loading = false;
          });
        }
      } catch (e) {
        setState(() {
          _location = 'Lokasi: ${position.latitude}, ${position.longitude}';
          _loading = false;
        });
      }
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _location = 'Gagal mendapatkan lokasi';
        _loading = false;
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
        _sudahKeluar = true;
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
        _sudahKeluar = true;
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
              child: SingleChildScrollView(
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
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                      if (_waktuKeluar != null)
                        Text("Waktu Keluar: $_waktuKeluar",
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                      SizedBox(height: 20),
                      if (_currentPosition != null)
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                ),
                                initialZoom: 16.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                  userAgentPackageName: 'com.example.app',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(
                                        _currentPosition!.latitude,
                                        _currentPosition!.longitude,
                                      ),
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.location_pin,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      SizedBox(height: 20),
                      if (!_sudahKeluar)
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 14),
                          ),
                          onPressed: () async {
                            if (_currentPosition != null) {
                              await _handleAbsen();
                              await _cekStatusAbsen();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lokasi belum tersedia'),
                                ),
                              );
                            }
                          },
                        ),
                      if (_sudahKeluar)
                        Text(
                          'Terima kasih, selamat berlibur!',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
