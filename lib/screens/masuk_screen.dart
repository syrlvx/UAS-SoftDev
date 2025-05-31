import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  Position? _currentPosition;

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
      setState(() {
        _loading = true;
      });

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

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Mengambil lokasi terlalu lama');
          },
        );
      } catch (e) {
        print('Error getting position: $e');
        setState(() {
          _location = 'Gagal mendapatkan posisi: ${e.toString()}';
          _loading = false;
        });
        return;
      }

      _currentPosition = position;

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Mengambil alamat terlalu lama');
          },
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String formattedLocation = '';

          // Membuat format alamat yang lebih rapi
          if (place.street?.isNotEmpty ?? false) {
            formattedLocation += place.street!;
          }
          if (place.subLocality?.isNotEmpty ?? false) {
            formattedLocation += formattedLocation.isNotEmpty ? ', ' : '';
            formattedLocation += place.subLocality!;
          }
          if (place.locality?.isNotEmpty ?? false) {
            formattedLocation += formattedLocation.isNotEmpty ? ', ' : '';
            formattedLocation += place.locality!;
          }

          setState(() {
            _location = formattedLocation;
            _loading = false;
          });
        } else {
          setState(() {
            _location = 'Lokasi tidak ditemukan';
            _loading = false;
          });
        }
      } catch (e) {
        print('Error getting placemark: $e');
        setState(() {
          _location = 'Gagal mendapatkan alamat';
          _loading = false;
        });
      }
    } catch (e) {
      print('Error in _getLocation: $e');
      setState(() {
        _location = 'Gagal mendapatkan lokasi: ${e.toString()}';
        _loading = false;
      });
    }
  }

  Future<void> _cekStatusAbsen() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null || _currentDate == null) {
        setState(() {
          _loading = false;
        });
        return;
      }

      final docRef = FirebaseFirestore.instance
          .collection('absensi')
          .where('user_id', isEqualTo: user.uid)
          .where('tanggal', isEqualTo: _currentDate);

      final querySnapshot = await docRef.get().catchError((error) {
        print('Error querying Firestore: $error');
        return null;
      });

      if (querySnapshot == null) {
        setState(() {
          _loading = false;
        });
        return;
      }

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        setState(() {
          if (data.containsKey('waktu_masuk') && data['waktu_masuk'] != null) {
            _waktuMasuk = DateFormat('HH:mm')
                .format((data['waktu_masuk'] as Timestamp).toDate());
            _sudahMasuk = true;
          }

          if (data.containsKey('waktu_keluar') &&
              data['waktu_keluar'] != null) {
            _waktuKeluar = DateFormat('HH:mm')
                .format((data['waktu_keluar'] as Timestamp).toDate());
            _sudahKeluar = true;
          }
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      print('Error checking attendance status: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _handleAbsen() async {
    setState(() {
      _loading = true;
    });

    try {
      // Check if current time is after 5 PM
      final now = DateTime.now();
      if (now.hour >= 17) {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Absensi tidak dapat dilakukan setelah jam 5 sore'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null || _currentDate == null) {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User atau tanggal tidak tersedia')),
        );
        return;
      }

      if (_currentPosition == null) {
        await _getLocation();
        if (_currentPosition == null || _location == null) {
          setState(() {
            _loading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lokasi tidak tersedia, coba lagi')),
          );
          return;
        }
      }

      final nowFormatted = DateFormat('HH:mm').format(DateTime.now());

      // Query untuk mencari dokumen absensi hari ini
      final querySnapshot = await FirebaseFirestore.instance
          .collection('absensi')
          .where('user_id', isEqualTo: user.uid)
          .where('tanggal', isEqualTo: _currentDate)
          .limit(1)
          .get();

      if (!_sudahMasuk) {
        // Jika belum ada dokumen absensi hari ini, buat baru
        if (querySnapshot.docs.isEmpty) {
          Map<String, dynamic> absenData = {
            'user_id': user.uid,
            'tanggal': _currentDate,
            'waktu_masuk': Timestamp.fromDate(DateTime.now()),
            'lokasi_masuk': _location,
            'keterangan':
                'Tepat waktu', // Bisa ditambahkan logika untuk menentukan status
          };

          await FirebaseFirestore.instance.collection('absensi').add(absenData);
        } else {
          // Jika sudah ada tapi belum ada waktu masuk (seharusnya tidak terjadi)
          await querySnapshot.docs.first.reference.update({
            'waktu_masuk': Timestamp.fromDate(DateTime.now()),
            'lokasi_masuk': _location,
          });
        }

        setState(() {
          _waktuMasuk = nowFormatted;
          _waktuKeluar = null;
          _sudahMasuk = true;
          _loading = false;
        });
      } else {
        // Update dokumen yang sudah ada dengan data keluar
        if (querySnapshot.docs.isNotEmpty) {
          Map<String, dynamic> updateData = {
            'waktu_keluar': Timestamp.fromDate(DateTime.now()),
            'lokasi_keluar': _location,
          };

          await querySnapshot.docs.first.reference.update(updateData);
        }

        setState(() {
          _waktuKeluar = nowFormatted;
          _sudahMasuk = false;
          _sudahKeluar = true;
          _loading = false;
        });
      }
    } catch (e) {
      print('Error handling attendance: $e');
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
      );
    }
  }

  bool _isWithinWorkingHours() {
    final now = DateTime.now();
    return now.hour >= 8 && now.hour < 17;
  }

  Color _getButtonColor() {
    if (!_isWithinWorkingHours()) {
      return Colors.grey;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final bool isButtonEnabled = _isWithinWorkingHours() && !_sudahKeluar;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                if (_currentPosition != null)
                  FlutterMap(
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
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: const Color.fromARGB(255, 228, 3, 3)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tanggal: ${DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now())}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontStyle: FontStyle
                                      .normal, // atau italic kalau mau miring
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(thickness: 1, color: Colors.grey[300]),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: const Color.fromARGB(255, 48, 133, 25)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Lokasi: ${_location ?? "-"}',
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontStyle: FontStyle.normal),
                              ),
                            ),
                          ],
                        ),
                        Divider(thickness: 1, color: Colors.grey[300]),
                        if (_waktuMasuk != null || _waktuKeluar != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_waktuMasuk != null)
                                Row(
                                  children: [
                                    Icon(Icons.login, color: Colors.grey),
                                    SizedBox(width: 10),
                                    Text(
                                      'Jam Masuk: $_waktuMasuk',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              if (_waktuKeluar != null)
                                Row(
                                  children: [
                                    Icon(Icons.logout, color: Colors.grey),
                                    SizedBox(width: 10),
                                    Text(
                                      'Jam Keluar: $_waktuKeluar',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // Navigasi ke riwayat aktivitas
                                },
                                icon: const Icon(Icons.history),
                                label: Text(
                                  'Aktivitas',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  side: BorderSide.none,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: isButtonEnabled
                                    ? () async {
                                        if (_currentPosition != null) {
                                          await _handleAbsen();
                                          await _cekStatusAbsen();
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Lokasi belum tersedia')),
                                          );
                                        }
                                      }
                                    : null,
                                icon: Icon(
                                  _sudahMasuk ? Icons.logout : Icons.login,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  _sudahMasuk ? 'Keluar' : 'Masuk',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _getButtonColor(),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  disabledBackgroundColor: Colors.grey,
                                  disabledForegroundColor: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_sudahKeluar)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                'Terima kasih, selamat berlibur!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
}
