import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:purelux/screens/akun_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeAdminScreen extends StatefulWidget {
  @override
  _HomeAdminScreenState createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen>
    with SingleTickerProviderStateMixin {
  bool isLoggedIn = false;
  String? username;
  String? role;
  bool isLoadingUser = true;
  late final TabController _tabController =
      TabController(length: 3, vsync: this);
  int _currentTabIndex = 0;

  // Dummy data untuk absensi
  final List<Map<String, dynamic>> absensiData = [
    {
      'tanggal': '2024-03-20',
      'jenis': 'Absensi',
      'status': 'Hadir',
      'nama': 'John Doe',
      'jam_masuk': '08:00:00',
      'jam_keluar': '17:00:00',
      'keterangan': 'Tepat Waktu'
    },
    {
      'tanggal': '2024-03-20',
      'jenis': 'Absensi',
      'status': 'Hadir',
      'nama': 'Jane Smith',
      'jam_masuk': '07:55:00',
      'jam_keluar': '17:05:00',
      'keterangan': 'Tepat Waktu'
    },
    {
      'tanggal': '2024-03-19',
      'jenis': 'Absensi',
      'status': 'Terlambat',
      'nama': 'Mike Johnson',
      'jam_masuk': '08:30:00',
      'jam_keluar': '17:00:00',
      'keterangan': 'Terlambat 30 menit'
    },
    {
      'tanggal': '2024-03-19',
      'jenis': 'Absensi',
      'status': 'Tidak Hadir',
      'nama': 'Sarah Wilson',
      'jam_masuk': '-',
      'jam_keluar': '-',
      'keterangan': 'Tidak ada keterangan'
    },
  ];

  bool sortAscending = false;
  String selectedStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          // ignore: avoid_print
          print("User document not found.");
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching user data: $e");
    }
  }

  final List<Map<String, dynamic>> riwayatData = [
    {
      'tanggal': '2024-03-20',
      'jenis': 'cuti',
      'status': 'Disetujui',
      'employeeName': 'John Doe',
      'keterangan': 'Cuti Tahunan',
      'linkFile': 'https://example.com/file1.pdf'
    },
    {
      'tanggal': '2024-03-19',
      'jenis': 'izin',
      'status': 'Pending',
      'employeeName': 'Jane Smith',
      'keterangan': 'Izin Sakit',
      'linkFile': 'https://example.com/file2.pdf'
    },
    {
      'tanggal': '2024-03-18',
      'jenis': 'cuti',
      'status': 'Ditolak',
      'employeeName': 'Mike Johnson',
      'keterangan': 'Cuti Melahirkan',
      'linkFile': 'https://example.com/file3.pdf'
    },
    {
      'tanggal': '2024-03-17',
      'jenis': 'izin',
      'status': 'Disetujui',
      'employeeName': 'Sarah Wilson',
      'keterangan': 'Izin Penting',
      'linkFile': 'https://example.com/file4.pdf'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200),
        child: Container(
          height: 200,
          decoration: const BoxDecoration(
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
              padding: const EdgeInsets.only(
                  top: 20, bottom: 20, left: 16, right: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.account_circle,
                        size: 50, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AccountScreen()),
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
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        role ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
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
              controller: _tabController,
              indicatorColor: Color.fromARGB(255, 127, 157, 195),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Absensi'),
                Tab(text: 'Izin & Cuti'),
                Tab(text: 'Alpha'),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                // TabBarView untuk konten
                TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRiwayatTab('Absensi'),
                    _buildRiwayatTab('Izin & Cuti'),
                    _buildRiwayatTab('Terlambat'),
                  ],
                ),
                // KIRI: Sort
                Positioned(
                  left: 16,
                  top: 1,
                  child: PopupMenuButton<String>(
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.sort,
                          color: Color.fromARGB(255, 127, 157, 195),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          sortAscending ? 'Terlama' : 'Terbaru',
                          style: GoogleFonts.poppins(
                            color: const Color.fromARGB(255, 127, 157, 195),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    offset: const Offset(0, 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: Colors.white,
                    elevation: 4,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'Terbaru',
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_upward,
                              color: !sortAscending
                                  ? const Color.fromARGB(255, 127, 157, 195)
                                  : Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Terbaru',
                              style: GoogleFonts.poppins(
                                color: !sortAscending
                                    ? const Color.fromARGB(255, 127, 157, 195)
                                    : Colors.grey,
                                fontWeight: !sortAscending
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'Terlama',
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_downward,
                              color: sortAscending
                                  ? const Color.fromARGB(255, 127, 157, 195)
                                  : Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Terlama',
                              style: GoogleFonts.poppins(
                                color: sortAscending
                                    ? const Color.fromARGB(255, 127, 157, 195)
                                    : Colors.grey,
                                fontWeight: sortAscending
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (mounted) {
                        setState(() {
                          sortAscending = (value == 'Terlama');
                        });
                      }
                    },
                  ),
                ),

                // KANAN: Filter
                if (_currentTabIndex != 2)
                  Positioned(
                    right: 16,
                    top: 7,
                    child: SizedBox(
                      width: 100,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color.fromARGB(255, 127, 157, 195),
                            width: 1,
                          ),
                        ),
                        child: PopupMenuButton<String>(
                          initialValue: selectedStatus,
                          offset: const Offset(0, 30),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    selectedStatus,
                                    style: GoogleFonts.poppins(
                                      color: const Color.fromARGB(
                                          255, 127, 157, 195),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Color.fromARGB(255, 127, 157, 195),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                          itemBuilder: (BuildContext context) {
                            if (_currentTabIndex == 0) {
                              return ['Semua', 'Hadir', 'Tidak Hadir']
                                  .map((value) {
                                return PopupMenuItem<String>(
                                  value: value,
                                  height: 35,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.poppins(
                                      color: const Color.fromARGB(
                                          255, 127, 157, 195),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList();
                            } else if (_currentTabIndex == 1) {
                              return [
                                'Semua',
                                'Izin',
                                'Cuti',
                                'Disetujui',
                                'Pending',
                                'Ditolak',
                              ].map((value) {
                                return PopupMenuItem<String>(
                                  value: value,
                                  height: 35,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.poppins(
                                      color: const Color.fromARGB(
                                          255, 127, 157, 195),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList();
                            } else {
                              return [
                                'Semua',
                                'Disetujui',
                                'Pending',
                                'Ditolak'
                              ].map((value) {
                                return PopupMenuItem<String>(
                                  value: value,
                                  height: 35,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.poppins(
                                      color: const Color.fromARGB(
                                          255, 127, 157, 195),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList();
                            }
                          },
                          onSelected: (String newValue) {
                            if (mounted) {
                              setState(() {
                                selectedStatus = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatTab(String jenis) {
    if (jenis == 'Absensi' || jenis == 'Terlambat') {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final now = DateTime.now();
      final checkTime =
          DateTime(now.year, now.month, now.day, 8, 15); // 08:15 AM

      return FutureBuilder<List<QuerySnapshot<Map<String, dynamic>>>>(
        // Fetch all users and today's absensi records
        future: Future.wait([
          FirebaseFirestore.instance.collection('user').get(),
          FirebaseFirestore.instance
              .collection('absensi')
              .where('tanggal', isEqualTo: today)
              .get(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(
                  'Error loading absensi data: ${snapshot.error ?? "No data"}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final usersDocs = snapshot.data![0].docs; // All users
          final absensiDocsToday =
              snapshot.data![1].docs; // Today's absensi records

          // Map absensi records by user_id for easy lookup
          Map<String, Map<String, dynamic>> absensiMap = {};
          for (var doc in absensiDocsToday) {
            final data = doc.data() as Map<String, dynamic>;
            absensiMap[data['user_id']] = data;
          }

          // Build a list of attendance records for each user today
          List<Map<String, dynamic>> dailyAttendanceList = [];

          for (var userDoc in usersDocs) {
            final userData = userDoc.data() as Map<String, dynamic>;
            final userId = userDoc.id;
            final username = userData['username'] ?? 'Unknown User';

            Map<String, dynamic> attendanceEntry = {
              'user_id': userId,
              'username': username,
              'tanggal': today,
              'jam_masuk': null,
              'jam_keluar': null,
              'status':
                  'Belum Absen', // Default status: belum absen (jika tidak ada record)
            };

            // Check if user has an absensi record for today
            if (absensiMap.containsKey(userId)) {
              final absensiData = absensiMap[userId]!;
              attendanceEntry['jam_masuk'] =
                  absensiData['waktu_masuk']; // Timestamp or null
              attendanceEntry['jam_keluar'] =
                  absensiData['waktu_keluar']; // Timestamp or null

              if (absensiData['waktu_masuk'] is Timestamp) {
                final DateTime entryTime =
                    (absensiData['waktu_masuk'] as Timestamp).toDate();
                // Check if entry time is after 8:15 AM
                if (entryTime.isAfter(checkTime)) {
                  attendanceEntry['status'] =
                      'Terlambat'; // Terlambat karena check-in lewat jam 8.15
                } else {
                  attendanceEntry['status'] =
                      'Hadir'; // Hadir, check-in tepat waktu atau lebih awal
                }
              } else {
                // Jika waktu_masuk ada record tapi null/bukan Timestamp
                attendanceEntry['status'] =
                    'Tidak Hadir'; // Record ada tapi waktu_masuk tidak valid/null (Masuk tab Terlambat)
              }
            } else {
              // No absensi record for today, status tetap 'Belum Absen' (Masuk tab Terlambat)
            }

            dailyAttendanceList.add(attendanceEntry);
          }

          // --- Filter list berdasarkan waktu saat ini (untuk kasus Belum Absen sebelum 8:15)
          List<Map<String, dynamic>> displayList =
              dailyAttendanceList.where((item) {
            // Jika status Belum Absen DAN jam masih sebelum 8:15, jangan tampilkan
            if (item['status'] == 'Belum Absen' && now.isBefore(checkTime)) {
              return false;
            }
            return true; // Tampilkan semua status lain, atau Belum Absen setelah 8:15
          }).toList();

          // Filter berdasarkan status yang dipilih DAN jenis tab
          List<Map<String, dynamic>> filteredList = displayList.where((item) {
            // Filter berdasarkan status yang dipilih dari PopupMenuButton
            bool statusMatch =
                (selectedStatus == 'Semua' || item['status'] == selectedStatus);

            // Filter berdasarkan jenis tab
            if (jenis == 'Absensi') {
              // Tab Absensi menampilkan Hadir dan Terlambat check-in
              return statusMatch &&
                  (item['status'] == 'Hadir' || item['status'] == 'Terlambat');
            } else if (jenis == 'Terlambat') {
              // Tab Terlambat menampilkan Tidak Hadir dan Belum Absen
              return statusMatch &&
                  (item['status'] == 'Tidak Hadir' ||
                      item['status'] == 'Belum Absen');
            }
            // Jika jenis tab tidak dikenali, tampilkan semua (atau logika default lainnya)
            return statusMatch; // Default fallback
          }).toList();

          // Sort berdasarkan nama pengguna
          filteredList.sort((a, b) {
            final aUsername = a['username'] as String;
            final bUsername = b['username'] as String;
            return sortAscending
                ? aUsername.compareTo(bUsername)
                : bUsername.compareTo(aUsername);
          });

          if (filteredList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.history,
                    size: 56,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada data $jenis hari ini',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // Display the daily attendance list
          return Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              children: [
                const SizedBox(height: 45),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];

                      // Format waktu
                      final waktuMasukTimestamp =
                          item['jam_masuk'] as Timestamp?;
                      final waktuMasuk = waktuMasukTimestamp != null
                          ? DateFormat('HH:mm:ss')
                              .format(waktuMasukTimestamp.toDate())
                          : '-';

                      final waktuKeluarTimestamp =
                          item['jam_keluar'] as Timestamp?;
                      final waktuKeluar = waktuKeluarTimestamp != null
                          ? DateFormat('HH:mm:ss')
                              .format(waktuKeluarTimestamp.toDate())
                          : '-';

                      // Tentukan status dan warna
                      String status = item['status'];
                      Color statusColor;
                      switch (status) {
                        case 'Hadir':
                          statusColor =
                              const Color.fromARGB(255, 127, 157, 195);
                          break;
                        case 'Tidak Hadir': // Warna merah untuk tidak hadir
                          statusColor = Colors.red;
                          break;
                        case 'Terlambat': // Warna oranye untuk terlambat check-in
                          statusColor = Colors.orange;
                          break;
                        case 'Belum Absen': // Warna abu-abu untuk belum absen
                          statusColor = Colors.grey;
                          break;
                        default:
                          statusColor =
                              Colors.grey; // Default or unknown status
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: statusColor,
                          ),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  color: statusColor,
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Absensi - ${item['status']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 17,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      item['username'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // KIRI
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            color: Colors.green,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 5),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Waktu Mulai',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                waktuMasuk,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    // KANAN
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            color:
                                                Color.fromARGB(255, 255, 0, 0),
                                            size: 18,
                                          ),
                                          const SizedBox(width: 5),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Waktu Selesai',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Color.fromARGB(
                                                      255, 255, 0, 0),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                waktuKeluar,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else if (jenis == 'Izin & Cuti') {
      // Get today's start and end
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('pengajuan').get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var docs = snapshot.data?.docs ?? [];

          // Filter untuk hari ini dan jenis izin/cuti di client side
          docs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final tanggal = (data['tanggal'] as Timestamp).toDate();
            final jenis = data['jenis'] as String;

            return tanggal.isAfter(startOfDay) &&
                tanggal.isBefore(endOfDay) &&
                (jenis == 'izin' || jenis == 'cuti');
          }).toList();

          // Filter based on selected status
          if (selectedStatus != 'Semua') {
            docs = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              if (selectedStatus == 'Izin') return data['jenis'] == 'izin';
              if (selectedStatus == 'Cuti') return data['jenis'] == 'cuti';
              return data['status'] == selectedStatus;
            }).toList();
          }

          // Sort documents
          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aDate = (aData['tanggal'] as Timestamp).toDate();
            final bDate = (bData['tanggal'] as Timestamp).toDate();
            return sortAscending
                ? aDate.compareTo(bDate)
                : bDate.compareTo(aDate);
          });

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.history,
                    size: 56,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada pengajuan $jenis hari ini',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color.fromARGB(255, 227, 241, 253),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengajuan Izin & Cuti Hari Ini',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 16, 126, 173),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                            .format(DateTime.now()),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final tanggal = (data['tanggal'] as Timestamp).toDate();
                      final formattedDate =
                          DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                              .format(tanggal);
                      final formattedWaktu =
                          DateFormat('dd/MM/yyyy').format(tanggal);

                      return IzinItem(
                        date: formattedDate,
                        title: data['keterangan'] ??
                            data['linkFile'] ??
                            'Tidak ada keterangan',
                        color: data['jenis'] == 'cuti'
                            ? Colors.purple
                            : Colors.green,
                        type: data['jenis'] == 'cuti' ? 'CUTI' : 'IZIN',
                        waktu: formattedWaktu,
                        status: data['status'] ?? 'Pending',
                        username: data['nama'] ?? 'Unknown User',
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else if (jenis == 'Lembur') {
      return const Center(
        child: Text('Fitur Lembur Segera Hadir'),
      );
    }

    return const Center(
      child: Text('Coming Soon'),
    );
  }
}

class IzinItem extends StatelessWidget {
  final String date, title, type, waktu, status, username;
  final Color color;

  const IzinItem({
    Key? key,
    required this.date,
    required this.title,
    required this.color,
    required this.type,
    required this.waktu,
    required this.status,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (date.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 10.0),
            child: Text(
              date,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description, color: color),
                Text(
                  type,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.black, // Warna teks hitam
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text('Nama        : $username',
                    style: GoogleFonts.poppins(color: Colors.black)),
                const SizedBox(height: 2),
                Text('Waktu       : $waktu',
                    style: GoogleFonts.poppins(color: Colors.black)),
                const SizedBox(height: 2),
                Text('Status Izin : $status',
                    style: GoogleFonts.poppins(color: Colors.black)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
