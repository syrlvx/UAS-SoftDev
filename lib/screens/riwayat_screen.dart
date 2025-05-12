import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:purelux/widgets/bottom_nav_bar.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RiwayatScreenState createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  final List<Map<String, String>> riwayatData = [
    {
      'tanggal': '2025-04-30',
      'jam': '08:30:00',
      'jenis': 'Absensi',
      'status': 'Hadir'
    },
    {
      'tanggal': '2025-04-29',
      'jam': '09:00:00',
      'jenis': 'Izin & Cuti',
      'status': 'Cuti Sakit'
    },
    {
      'tanggal': '2025-04-28',
      'jam': '18:00:00',
      'jenis': 'Lembur',
      'status': 'Disetujui'
    },
    {
      'tanggal': '2025-04-27',
      'jam': '08:15:00',
      'jenis': 'Absensi',
      'status': 'Tidak Hadir'
    },
    {
      'tanggal': '2025-04-26',
      'jam': '12:00:00',
      'jenis': 'Izin & Cuti',
      'status': 'Cuti Tahunan'
    },
    {
      'tanggal': '2025-04-25',
      'jam': '17:30:00',
      'jenis': 'Lembur',
      'status': 'Pending'
    },
  ];

  bool sortAscending = false;
  String selectedStatus = 'Semua';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(300),
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
                    const SizedBox(
                        height: 70), // Tambahkan ruang agar isi turun

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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatTab(String jenis) {
    // Filter data berdasarkan jenis dan status yang dipilih
    final filteredData = riwayatData
        .where((item) =>
            item['jenis'] == jenis &&
            (selectedStatus == 'Semua' || item['status'] == selectedStatus))
        .toList();

    // Sort data sesuai dengan urutan yang dipilih (Terbaru ke Terlama atau Terlama ke Terbaru)
    if (sortAscending) {
      filteredData.sort((a, b) => DateTime.parse(a['tanggal']!)
          .compareTo(DateTime.parse(b['tanggal']!)));
    } else {
      filteredData.sort((a, b) => DateTime.parse(b['tanggal']!)
          .compareTo(DateTime.parse(a['tanggal']!)));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Riwayat $jenis',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
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
                    .format(DateTime.parse(item['tanggal']!));
                final waktu = item['jam']!.substring(0, 8);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
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
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${item['jenis']} - ${item['status']}',
                            style: TextStyle(
                              fontSize: 18,
                              color: item['status'] == 'Hadir'
                                  ? const Color.fromARGB(255, 255, 255, 255)
                                  : const Color.fromARGB(255, 255, 255, 255),
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
                                          waktu,
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

                              // KANAN (duplikat)
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
                                          waktu,
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
            ),
          ),
        ],
      ),
    );
  }
}
