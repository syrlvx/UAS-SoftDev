import 'package:flutter/material.dart';
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

  Future<void> _loadAbsensiData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final String uid = currentUser.uid;
      List<Map<String, dynamic>> allData = [];

      // Mendapatkan 30 hari terakhir
      final DateTime today = DateTime.now();
      final List<DateTime> last30Days = List.generate(
        30,
        (index) => today.subtract(Duration(days: index)),
      );

      // Set untuk melacak tanggal yang sudah ada data absensinya
      Set<String> datesWithAttendance = {};

      // 1. Muat data absensi untuk setiap tanggal (30 hari terakhir)
      for (DateTime day in last30Days) {
        final String formattedDate = DateFormat('yyyy-MM-dd').format(day);

        try {
          // Periksa apakah subcollection tanggal ini ada
          final collectionRef = _firestore
              .collection('user_data')
              .doc(uid)
              .collection(formattedDate);

          final QuerySnapshot snapshot = await collectionRef.limit(1).get();

          // Jika ada dokumen di subcollection tanggal ini
          if (snapshot.docs.isNotEmpty) {
            // Ambil data dari dokumen pertama (seharusnya hanya ada satu untuk absensi harian)
            final DocumentSnapshot attendanceDoc = snapshot.docs.first;
            Map<String, dynamic> data =
                attendanceDoc.data() as Map<String, dynamic>;

            // Tambahkan informasi tanggal dan jenis
            data['tanggal'] = formattedDate;
            data['jenis'] = 'Absensi';
            data['status'] = data['status'] ??
                'Hadir'; // Default ke 'Hadir' jika tidak ada status

            // Pastikan data memiliki nilai default
            data['jam_masuk'] ??= '08:00:00';
            data['jam_keluar'] ??= '17:00:00';

            allData.add(data);
            datesWithAttendance.add(formattedDate);
          }
          // Jika tidak ada dokumen dan hari kerja (bukan weekend), tambahkan sebagai 'Tidak Hadir'
          else {
            final int weekday = day.weekday; // 1 = Senin, 7 = Minggu
            if (weekday < 6) {
              // Hari kerja (Senin-Jumat)
              allData.add({
                'tanggal': formattedDate,
                'jam_masuk': '08:00:00',
                'jam_keluar': '17:00:00',
                'jenis': 'Absensi',
                'status': 'Tidak Hadir',
              });
            }
          }
        } catch (e) {
          debugPrint('Error checking attendance for date $formattedDate: $e');
        }
      }

      // 2. Load data izin & cuti (juga dari subcollection tanggal)
      for (DateTime day in last30Days) {
        final String formattedDate = DateFormat('yyyy-MM-dd').format(day);

        try {
          // Periksa apakah ada dokumen izin & cuti untuk tanggal ini
          final collectionRef = _firestore
              .collection('user_data')
              .doc(uid)
              .collection(formattedDate);

          final QuerySnapshot izinCutiDocs = await collectionRef
              .where('jenis', isEqualTo: 'Izin & Cuti')
              .get();

          for (var doc in izinCutiDocs.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['tanggal'] = formattedDate;

            // Pastikan field yang diperlukan ada
            data['jam_masuk'] ??= '08:00:00';
            data['jam_keluar'] ??= '17:00:00';

            allData.add(data);
          }
        } catch (e) {
          debugPrint('Error checking izin & cuti for date $formattedDate: $e');
        }
      }

      // 3. Load data lembur (juga dari subcollection tanggal)
      for (DateTime day in last30Days) {
        final String formattedDate = DateFormat('yyyy-MM-dd').format(day);

        try {
          // Periksa apakah ada dokumen lembur untuk tanggal ini
          final collectionRef = _firestore
              .collection('user_data')
              .doc(uid)
              .collection(formattedDate);

          final QuerySnapshot lemburDocs =
              await collectionRef.where('jenis', isEqualTo: 'Lembur').get();

          for (var doc in lemburDocs.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['tanggal'] = formattedDate;

            // Pastikan field yang diperlukan ada
            data['jam_masuk'] ??= '08:00:00';
            data['jam_keluar'] ??= '17:00:00';

            allData.add(data);
          }
        } catch (e) {
          debugPrint('Error checking lembur for date $formattedDate: $e');
        }
      }

      setState(() {
        absensiData = allData;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error in _loadAbsensiData: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(150),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF001F3D), // Biru navy gelap
                  Color(0xFFFFFFFF)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BottomNavBar()),
                        );
                      },
                    ),
                    const Spacer(),
                    const Text(
                      'Riwayat',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 70),
                    const Spacer(),
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
                indicatorColor: Color.fromARGB(255, 127, 157, 195),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Absensi'),
                  Tab(text: 'Izin & Cuti'),
                  Tab(text: 'Lembur'),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Stack(
                  children: [
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
                              style: const TextStyle(
                                color: Color.fromARGB(255, 127, 157, 195),
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
                                  style: TextStyle(
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
                                  style: TextStyle(
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
                          setState(() {
                            sortAscending = (value == 'Terlama');
                          });
                        },
                      ),
                    ),
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
                                      style: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 127, 157, 195),
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
                            itemBuilder: (BuildContext context) => [
                              'Semua',
                              'Hadir',
                              'Tidak Hadir',
                              'Terlambat',
                            ].map((String value) {
                              return PopupMenuItem<String>(
                                value: value,
                                height: 35,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 127, 157, 195),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                            onSelected: (String newValue) {
                              setState(() {
                                selectedStatus = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
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
                                  _buildRiwayatTab('Lembur'),
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
                Text(
                  'Detail Riwayat $jenis',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 16, 126, 173),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Informasi lebih lanjut tentang riwayat $jenis, termasuk status dan tanggal terkait.',
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
                            style: const TextStyle(
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
                                      Icons.location_on,
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
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        const Text(
                                          'Waktu Mulai',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          waktuMulai.substring(0, 8),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        if (item['lokasi_masuk'] != null) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            item['lokasi_masuk'],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
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
                                      color: Colors.orange,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 5),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tanggal,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        const Text(
                                          'Waktu Selesai',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          waktuSelesai.substring(0, 8),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        if (item['lokasi_keluar'] != null) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            item['lokasi_keluar'],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (item['keterangan'] != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8.0),
                            color: Colors.grey[100],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Keterangan:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item['keterangan'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
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
}
