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
  bool isLoggedIn = false;
  String? username;
  String? role;
  bool isLoadingUser = true;

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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
                          size: 60, color: Colors.white),
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
              child: const TabBar(
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
                    icon: const Row(
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
                      const PopupMenuItem<String>(
                          value: 'Terbaru ke Terlama',
                          child: Text('Terbaru ke Terlama')),
                      const PopupMenuItem<String>(
                          value: 'Terlama ke Terbaru',
                          child: Text('Terlama ke Terbaru')),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: PopupMenuButton<String>(
                      initialValue: selectedStatus,
                      offset: const Offset(0, 40),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedStatus,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      onSelected: (String newValue) {
                        setState(() {
                          selectedStatus = newValue;
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        // Get current tab index
                        final currentTab =
                            DefaultTabController.of(context).index;

                        if (currentTab == 0) {
                          // Tab Absensi
                          return [
                            'Semua',
                            'Hadir',
                            'Tidak Hadir',
                            'Terlambat',
                          ].map<PopupMenuItem<String>>((String value) {
                            return PopupMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          }).toList();
                        } else if (currentTab == 1) {
                          // Tab Izin & Cuti
                          return [
                            'Semua',
                            'Izin',
                            'Cuti',
                            'Disetujui',
                            'Pending',
                            'Ditolak',
                          ].map<PopupMenuItem<String>>((String value) {
                            return PopupMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          }).toList();
                        } else {
                          // Tab Lembur
                          return [
                            'Semua',
                            'Disetujui',
                            'Pending',
                            'Ditolak',
                          ].map<PopupMenuItem<String>>((String value) {
                            return PopupMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          }).toList();
                        }
                      },
                    ),
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
    if (jenis == 'Absensi') {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('absensi')
            .where('tanggal', isEqualTo: today)
            .get(),
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

          // Filter berdasarkan status yang dipilih
          if (selectedStatus != 'Semua') {
            docs = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['status'] == selectedStatus;
            }).toList();
          }

          // Sort berdasarkan waktu masuk
          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = (aData['waktu_masuk'] as Timestamp?)?.toDate() ??
                DateTime(1900);
            final bTime = (bData['waktu_masuk'] as Timestamp?)?.toDate() ??
                DateTime(1900);
            return sortAscending
                ? aTime.compareTo(bTime)
                : bTime.compareTo(aTime);
          });

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada data $jenis hari ini',
                    style: const TextStyle(
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
                      const Text(
                        'Absensi Hari Ini',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 16, 126, 173),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                            .format(DateTime.now()),
                        style: const TextStyle(
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

                      // Get user data
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('user')
                            .doc(data['user_id'])
                            .get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Card(
                              child: ListTile(
                                title:
                                    Center(child: CircularProgressIndicator()),
                              ),
                            );
                          }

                          final userData = userSnapshot.data?.data()
                              as Map<String, dynamic>?;
                          final username =
                              userData?['username'] ?? 'Unknown User';

                          // Format waktu
                          final waktuMasuk = data['waktu_masuk'] != null
                              ? DateFormat('HH:mm:ss').format(
                                  (data['waktu_masuk'] as Timestamp).toDate())
                              : '-';
                          final waktuKeluar = data['waktu_keluar'] != null
                              ? DateFormat('HH:mm:ss').format(
                                  (data['waktu_keluar'] as Timestamp).toDate())
                              : '-';

                          // Tentukan status dan warna
                          String status = 'Hadir';
                          Color statusColor =
                              const Color.fromARGB(255, 127, 157, 195);

                          if (waktuMasuk == '-') {
                            status = 'Tidak Hadir';
                            statusColor = Colors.red;
                          } else {
                            // Check if late (after 08:00)
                            final masuk =
                                (data['waktu_masuk'] as Timestamp).toDate();
                            final jamDelapan = DateTime(
                              masuk.year,
                              masuk.month,
                              masuk.day,
                              8,
                              0,
                            );
                            if (masuk.isAfter(jamDelapan)) {
                              status = 'Terlambat';
                              statusColor = Colors.orange;
                            }
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: statusColor,
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    color: statusColor,
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Absensi - $status',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          username,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    color: Colors.white,
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
                                                  const Text(
                                                    'Waktu Mulai',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    waktuMasuk,
                                                    style: const TextStyle(
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
                                                color: Colors.green,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 5),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Waktu Selesai',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    waktuKeluar,
                                                    style: const TextStyle(
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
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada pengajuan $jenis hari ini',
                    style: const TextStyle(
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
                      const Text(
                        'Pengajuan Izin & Cuti Hari Ini',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 16, 126, 173),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                            .format(DateTime.now()),
                        style: const TextStyle(
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
    }

    // Placeholder for other tabs
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
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description, color: color),
                Text(
                  type,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            title: Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text('Nama        : $username'),
                Text('Waktu        : $waktu'),
                Text('Status Izin  : $status'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
