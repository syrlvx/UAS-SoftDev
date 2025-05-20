import 'package:flutter/material.dart';

class RekapAbsensiPage extends StatelessWidget {
  const RekapAbsensiPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          title: const Text('Rekap Absensi'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'ABSENSI'),
              Tab(text: 'IZIN & CUTI'),
              Tab(text: 'LEMBUR'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('ABSENSI')),
            IzinCutiTab(),
            Center(child: Text('LEMBUR')),
          ],
        ),
      ),
    );
  }
}

class IzinCutiTab extends StatelessWidget {
  const IzinCutiTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari ...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: const [
              IzinItem(
                date: 'Senin, 17 Feb 2020',
                title: 'masih sakit kepala , meriap dingin',
                color: Colors.green,
                type: 'SAKIT',
                waktu: '17/2/2020 - 17/2/2020',
                status: 'Belum Disetujui ',
              ),
              IzinItem(
                date: '',
                title: 'sakit infeksi saluran kemih',
                color: Colors.green,
                type: 'SAKIT',
                waktu: '16/2/2020 - 16/2/2020',
                status: 'Belum Disetujui ',
              ),
              IzinItem(
                date: 'Minggu, 16 Feb 2020',
                title: 'izin anak sakit',
                color: Colors.purple,
                type: 'IZIN',
                waktu: '16/2/2020 - 16/2/2020',
                status: 'Belum Disetujui ',
              ),
            ],
          ),
        )
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
              style: const TextStyle(fontWeight: FontWeight.bold),
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
