import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:purelux/widgets/bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  _RiwayatScreenState createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> absensiData = [];
  bool isLoading = true;
  bool sortAscending = false;
  String selectedStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadAbsensiData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadAbsensiData() async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      // Mendapatkan 30 hari terakhir
      final DateTime today = DateTime.now();
      final List<DateTime> last30Days = List.generate(
        30,
        (index) => today.subtract(Duration(days: index)),
      );

      // Format tanggal untuk query
      final List<String> formattedDates = last30Days
          .map((date) => DateFormat('yyyy-MM-dd').format(date))
          .toList();

      try {
        // Query koleksi absensi untuk data 30 hari terakhir
        final QuerySnapshot absensiSnapshot = await _firestore
            .collection('absensi')
            .where('user_id', isEqualTo: currentUser.uid)
            .where('tanggal', whereIn: formattedDates)
            .get();

        List<Map<String, dynamic>> allData = [];

        for (var doc in absensiSnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Konversi data untuk menyesuaikan dengan format yang diharapkan UI
          Map<String, dynamic> formattedData = {
            'tanggal': data['tanggal'],
            'jenis': 'Absensi',
            'status': 'Hadir', // Default status, akan diubah jika terlambat
            'jam_masuk': data['waktu_masuk'] != null
                ? DateFormat('HH:mm:ss')
                    .format((data['waktu_masuk'] as Timestamp).toDate())
                : '08:00:00',
            'jam_keluar': data['waktu_keluar'] != null
                ? DateFormat('HH:mm:ss')
                    .format((data['waktu_keluar'] as Timestamp).toDate())
                : '17:00:00',
            'keterangan': data['keterangan'] ?? '',
          };

          // Cek jika terlambat (waktu_masuk > 08:15)
          if (data['waktu_masuk'] is Timestamp) {
            final DateTime entryTime =
                (data['waktu_masuk'] as Timestamp).toDate();
            // Check if entry time is after 8:15 AM (8 hours and 15 minutes)
            if (entryTime.hour > 8 ||
                (entryTime.hour == 8 && entryTime.minute > 15)) {
              formattedData['status'] = 'Terlambat';
            }
          } else if (data['waktu_masuk'] != null) {
            // Handle cases where waktu_masuk might not be a Timestamp, but is not null
            // Depending on your data, you might need different handling here.
            // For now, we'll just assume it's not late if it's not a Timestamp.
          }

          allData.add(formattedData);
        }

        // Tambahkan data "Tidak Hadir" untuk tanggal yang tidak ada di database
        for (String date in formattedDates) {
          bool dateExists = allData.any((item) => item['tanggal'] == date);
          if (!dateExists) {
            // Tambahkan "Tidak Hadir" untuk semua hari tanpa absensi
            allData.add({
              'tanggal': date,
              'jenis': 'Absensi',
              'status': 'Tidak Hadir',
              'jam_masuk': '08:00:00',
              'jam_keluar': '17:00:00',
              'keterangan': 'Tidak hadir',
            });
          }
        }

        if (mounted) {
          setState(() {
            absensiData = allData;
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error querying absensi: $e');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error in _loadAbsensiData: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Riwayat',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BottomNavBar()),
              );
            },
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF001F3D), // Biru navy gelap
                  Color(0xFFFFFFFF),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          toolbarHeight: 60, // untuk tinggi AppBar
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                indicatorColor: const Color.fromARGB(255, 127, 157, 195),
                labelColor: const Color.fromARGB(255, 127, 157, 195),
                unselectedLabelColor: Colors.grey,
                labelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Absensi'),
                  Tab(text: 'Izin & Cuti'),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Stack(
                  children: [
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
                                        ? const Color.fromARGB(
                                            255, 127, 157, 195)
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
                                        ? const Color.fromARGB(
                                            255, 127, 157, 195)
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                              final currentTab =
                                  DefaultTabController.of(context).index;

                              if (currentTab == 0) {
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
                              } else if (currentTab == 1) {
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

                    // TAMPILAN
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 40,
                      bottom: 0,
                      child: Container(
                        color: Colors.white,
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : TabBarView(
                                children: [
                                  _buildRiwayatTab('Absensi'),
                                  _buildRiwayatTab('Izin & Cuti'),
                                ],
                              ),
                      ),
                    ),
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
    if (jenis == 'Izin & Cuti') {
      return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('pengajuan')
            .where('userId', isEqualTo: _auth.currentUser?.uid)
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

          // Filter untuk Izin & Cuti
          docs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final jenisPengajuan = data['jenis'] as String;
            return jenisPengajuan == 'izin' || jenisPengajuan == 'cuti';
          }).toList();

          // Filter berdasarkan status yang dipilih
          if (selectedStatus != 'Semua') {
            docs = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              if (selectedStatus.toLowerCase() == 'izin' ||
                  selectedStatus.toLowerCase() == 'cuti') {
                return data['jenis'] == selectedStatus.toLowerCase();
              } else {
                return data['status'] == selectedStatus;
              }
            }).toList();
          }

          // Sort documents
          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aDate = (aData['createdAt'] as Timestamp).toDate();
            final bDate = (bData['createdAt'] as Timestamp).toDate();
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
                    'Tidak ada data $jenis',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // Group documents by date
          Map<String, List<QueryDocumentSnapshot>> groupedDocs = {};
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final tanggal = (data['tanggal'] as Timestamp).toDate();
            final formattedDate =
                DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(tanggal);

            if (!groupedDocs.containsKey(formattedDate)) {
              groupedDocs[formattedDate] = [];
            }
            groupedDocs[formattedDate]!.add(doc);
          }

          // Convert grouped docs to list of entries
          List<MapEntry<String, List<QueryDocumentSnapshot>>> sortedEntries =
              groupedDocs.entries.toList();

          // Sort entries by date
          sortedEntries.sort((a, b) {
            final aDate =
                DateFormat('EEEE, dd MMMM yyyy', 'id_ID').parse(a.key);
            final bDate =
                DateFormat('EEEE, dd MMMM yyyy', 'id_ID').parse(b.key);
            return sortAscending
                ? aDate.compareTo(bDate)
                : bDate.compareTo(aDate);
          });

          return ListView.builder(
            itemCount: sortedEntries.length,
            itemBuilder: (context, index) {
              final entry = sortedEntries[index];
              final date = entry.key;
              final docsForDate = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  ...docsForDate.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final tanggal = (data['tanggal'] as Timestamp).toDate();
                    final formattedWaktu =
                        DateFormat('dd/MM/yyyy').format(tanggal);

                    return IzinItem(
                      date:
                          '', // Empty date since we're showing it in the group header
                      title: data['keterangan'] ??
                          data['linkFile'] ??
                          'Tidak ada keterangan',
                      color: data['jenis'] == 'cuti'
                          ? Colors.purple
                          : Colors.green,
                      type: data['jenis'] == 'cuti' ? 'CUTI' : 'IZIN',
                      waktu: formattedWaktu,
                      status: data['status'] ?? 'Pending',
                    );
                  }).toList(),
                ],
              );
            },
          );
        },
      );
    }

    // Filter data berdasarkan jenis dan status yang dipilih
    final filteredData = absensiData
        .where((item) =>
            item['jenis'] == jenis &&
            (selectedStatus == 'Semua' || item['status'] == selectedStatus))
        .toList();

    // Sort data sesuai dengan urutan yang dipilih
    if (sortAscending) {
      filteredData.sort((a, b) => a['tanggal'].compareTo(b['tanggal']));
    } else {
      filteredData.sort((a, b) => b['tanggal'].compareTo(a['tanggal']));
    }

    if (filteredData.isEmpty) {
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
              'Tidak ada data $jenis',
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
          Flexible(
            child: ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final item = filteredData[index];
                final tanggal = DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                    .format(DateTime.parse(item['tanggal']));
                final waktuMulai = item['jam_masuk'] ?? '08:00:00';
                final waktuSelesai = item['jam_keluar'] ?? '17:00:00';

                // Menggunakan warna yang berbeda berdasarkan status
                Color statusColor;
                switch (item['status']) {
                  case 'Hadir':
                    statusColor = const Color.fromARGB(255, 127, 157, 195);
                    break;
                  case 'Tidak Hadir':
                    statusColor = Colors.red;
                    break;
                  case 'Terlambat':
                    statusColor = Colors.orange;
                    break;
                  case 'Disetujui':
                    statusColor = Colors.green;
                    break;
                  case 'Pending':
                    statusColor = Colors.orange;
                    break;
                  case 'Ditolak':
                    statusColor = Colors.red;
                    break;
                  default:
                    statusColor = const Color.fromARGB(255, 127, 157, 195);
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
                          child: Text(
                            '${item['jenis']} - ${item['status']}',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // KIRI
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          tanggal,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
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
                                          waktuMulai.substring(0, 8),
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      color: Color.fromARGB(255, 255, 0, 0),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 5),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tanggal,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Waktu Selesai',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color:
                                                Color.fromARGB(255, 255, 0, 0),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          waktuSelesai.substring(0, 8),
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
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
  }

  Widget _izinDetail(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class IzinItem extends StatelessWidget {
  final String date, title, type, waktu, status;
  final Color color;

  const IzinItem({
    Key? key,
    required this.date,
    required this.title,
    required this.color,
    required this.type,
    required this.waktu,
    required this.status,
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
          child: ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description, color: color),
                Text(
                  type,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  'Waktu         : $waktu',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Status Izin  : $status',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
