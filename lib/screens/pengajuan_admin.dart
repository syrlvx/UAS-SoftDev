import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PengajuanAdminScreen extends StatefulWidget {
  @override
  _PengajuanAdminScreenState createState() => _PengajuanAdminScreenState();
}

class _PengajuanAdminScreenState extends State<PengajuanAdminScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(90),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            bottom: TabBar(
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              tabs: [
                Tab(text: "Cuti"),
                Tab(text: "Izin"),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            PengajuanList(jenis: 'cuti'),
            PengajuanList(jenis: 'izin'),
          ],
        ),
      ),
    );
  }
}

class PengajuanList extends StatefulWidget {
  final String jenis;
  const PengajuanList({required this.jenis});

  @override
  _PengajuanListState createState() => _PengajuanListState();
}

class _PengajuanListState extends State<PengajuanList> {
  Map<String, String> statusMap = {};

  final List<Map<String, String>> allData = [
    {
      "id": "1",
      "nama": "Siti Aminah",
      "keterangan": "Cuti tahunan 5 hari",
      "tanggal": "5–9 Mei",
      "bukti": "https://drive.google.com/example",
      "jenis": "cuti"
    },
    {
      "id": "2",
      "nama": "Budi Santoso",
      "keterangan": "Izin keperluan keluarga",
      "tanggal": "10–12 Mei",
      "jenis": "izin"
    },
  ];

  @override
  void initState() {
    super.initState();
    //loadStatus();
  }

  Future<void> loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var item in allData) {
        final id = item['id']!;
        statusMap[id] = prefs.getString('status_$id') ?? 'PENDING';
      }
    });
  }

  Future<void> updateStatus(String id, String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('status_$id', status);
    setState(() {
      statusMap[id] = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data =
        allData.where((item) => item['jenis'] == widget.jenis).toList();

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final id = item['id']!;
        final status = statusMap[id] ?? 'PENDING';

        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(item['nama'] ?? ''),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Keterangan: ${item['keterangan'] ?? ''}"),
                    if (widget.jenis == 'cuti' && item['bukti'] != null) ...[
                      SizedBox(height: 8),
                      Text("Bukti:"),
                      GestureDetector(
                        onTap: () {
                          // Bisa diarahkan ke WebView atau link terbuka
                        },
                        child: Text(
                          item['bukti'] ?? '',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      updateStatus(id, 'DISETUJUI');
                    },
                    child: Text("Konfirmasi"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      updateStatus(id, 'DITOLAK');
                    },
                    child: Text("Tolak"),
                  ),
                ],
              ),
            );
          },
          child: Card(
            color: Colors.pink[50],
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(item['nama'] ?? ''),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['keterangan'] ?? ''),
                  Text(item['tanggal'] ?? ''),
                ],
              ),
              trailing: Text(
                status,
                style: TextStyle(
                  color: status == 'PENDING'
                      ? Colors.orange
                      : status == 'DISETUJUI'
                          ? Colors.green
                          : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
