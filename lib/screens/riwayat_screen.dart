import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:purelux/widgets/bottom_nav_bar.dart';

class RiwayatScreen extends StatefulWidget {
  @override
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
          preferredSize: Size.fromHeight(100),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.indigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BottomNavBar()),
                        );
                      },
                    ),
                    Spacer(),
                    Text(
                      'Riwayat',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Sort Button
                  PopupMenuButton<String>(
                    icon: Row(
                      children: [
                        Icon(Icons.sort, color: Colors.blue), // Ikon tetap biru
                        SizedBox(width: 4),
                        Text('Sort',
                            style: TextStyle(
                                color: Colors.blue)), // Teks tetap biru
                      ],
                    ),
                    onSelected: (value) {
                      setState(() {
                        sortAscending = (value == 'Terlama ke Terbaru');
                      });
                    },
                    color:
                        Colors.white, // Mengubah background menu menjadi putih
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          8.0), // Menambahkan pembulatan pada sudut
                    ),
                    elevation:
                        4, // Menambahkan sedikit bayangan agar lebih jelas
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'Terbaru ke Terlama',
                        child: Container(
                          color: Colors
                              .white, // Mengubah background item menjadi putih
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text('Terbaru ke Terlama'),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'Terlama ke Terbaru',
                        child: Container(
                          color: Colors
                              .white, // Mengubah background item menjadi putih
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text('Terlama ke Terbaru'),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  // Status Filter
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
                        value: value,
                        child: Text(value),
                      );
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
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Riwayat $jenis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Informasi lebih lanjut tentang riwayat $jenis, termasuk status dan tanggal terkait.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Flexible(
            child: ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final item = filteredData[index];
                final tanggal = DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                    .format(DateTime.parse(item['tanggal']!));
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
                              color: item['status'] == 'Hadir'
                                  ? const Color.fromARGB(255, 255, 255, 255)
                                  : const Color.fromARGB(255, 255, 255, 255),
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
                              // KIRI
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                    SizedBox(width: 5),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tanggal,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          'Waktu Mulai',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          waktu,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(width: 10),

                              // KANAN (duplikat)
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.orange,
                                      size: 18,
                                    ),
                                    SizedBox(width: 5),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tanggal,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          'Waktu Selesai',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          waktu,
                                          style: TextStyle(
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
