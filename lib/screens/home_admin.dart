import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:purelux/screens/akun_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeAdminScreen extends StatefulWidget {
  @override
  _HomeAdminScreenState createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  late Timer _timer;
  late String _currentTime;
  bool isLoggedIn = false;

  String? username;
  String? role;
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _currentTime = _getCurrentTime();
    _startTimer();
    _fetchUserData();
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

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute}:${now.second}';
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

  final List<Map<String, String>> riwayatData = [
    {
      'tanggal': '2025-04-30',
      'jam': '08:30:00',
      'jenis': 'Absensi',
      'status': 'Hadir',
      'employeeName': 'John Doe'
    },
    {
      'tanggal': '2025-04-30',
      'jam': '09:00:00',
      'jenis': 'Izin & Cuti',
      'status': 'Cuti Sakit',
      'employeeName': 'Jane Smith'
    },
    {
      'tanggal': '2025-04-30',
      'jam': '18:00:00',
      'jenis': 'Lembur',
      'status': 'Disetujui',
      'employeeName': 'Chris Lee'
    },
    {
      'tanggal': '2025-04-29',
      'jam': '08:15:00',
      'jenis': 'Absensi',
      'status': 'Tidak Hadir',
      'employeeName': 'Michael Johnson'
    },
    {
      'tanggal': '2025-04-29',
      'jam': '12:00:00',
      'jenis': 'Izin & Cuti',
      'status': 'Cuti Tahunan',
      'employeeName': 'Sarah Brown'
    },
    {
      'tanggal': '2025-04-29',
      'jam': '17:30:00',
      'jenis': 'Lembur',
      'status': 'Pending',
      'employeeName': 'James White'
    },
  ];

  bool sortAscending = false;
  String selectedStatus = 'Semua';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(200),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF001F3D), Color(0xFFFFFFFF)],
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
                padding:
                    EdgeInsets.only(top: 20, bottom: 20, left: 16, right: 16),
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
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                indicatorColor: Colors.blue,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Absensi'),
                  Tab(text: 'Izin & Cuti'),
                  Tab(text: 'Lembur'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  PopupMenuButton<String>(
                    icon: Row(
                      children: [
                        Icon(Icons.sort, color: Colors.blue),
                        SizedBox(width: 4),
                        Text('Sort', style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                    onSelected: (value) {
                      setState(() {
                        sortAscending = (value == 'Terlama ke Terbaru');
                      });
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                          value: 'Terbaru ke Terlama',
                          child: Text('Terbaru ke Terlama')),
                      PopupMenuItem<String>(
                          value: 'Terlama ke Terbaru',
                          child: Text('Terlama ke Terbaru')),
                    ],
                  ),
                  Spacer(),
                  DropdownButton<String>(
                    value: selectedStatus,
                    onChanged: (newValue) {
                      setState(() {
                        selectedStatus = newValue!;
                      });
                    },
                    items: [
                      'Semua',
                      'Hadir',
                      'Cuti Sakit',
                      'Disetujui',
                      'Tidak Hadir',
                      'Pending'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                          value: value, child: Text(value));
                    }).toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: TabBarView(
                  children: [
                    _buildRiwayatTab('Absensi'),
                    _buildRiwayatTab('Izin & Cuti'),
                    _buildRiwayatTab('Lembur'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatTab(String jenis) {
    final filteredData = riwayatData
        .where((item) =>
            item['jenis'] == jenis &&
            (selectedStatus == 'Semua' || item['status'] == selectedStatus))
        .toList();

    if (sortAscending) {
      filteredData.sort((a, b) => DateTime.parse(a['tanggal']!)
          .compareTo(DateTime.parse(b['tanggal']!)));
    } else {
      filteredData.sort((a, b) => DateTime.parse(b['tanggal']!)
          .compareTo(DateTime.parse(a['tanggal']!)));
    }

    final groupedData = <String, List<Map<String, String>>>{};
    for (var item in filteredData) {
      final date = item['tanggal']!;
      if (groupedData.containsKey(date)) {
        groupedData[date]?.add(item);
      } else {
        groupedData[date] = [item];
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: groupedData.length,
        itemBuilder: (context, dateIndex) {
          final date = groupedData.keys.toList()[dateIndex];
          final dateItems = groupedData[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                    .format(DateTime.parse(date)),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ...dateItems.map((item) {
                final waktu = item['jam']!.substring(0, 8);

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue,
                    ),
                    child: Column(
                      children: [
                        Container(
                          color: Colors.blue,
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            '${item['jenis']} - ${item['status']}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Karyawan: ${item['employeeName']}',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Waktu Mulai: $waktu',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
