import 'package:flutter/material.dart';

class RekapPengajuanScreen extends StatelessWidget {
  const RekapPengajuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('Rekap Pengajuan'),
          centerTitle: true, // <- ini membuat title berada di tengah
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF001F3D), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          IzinCard(
            type: 'Izin',
            status: 'Ditolak',
            statusDate: '20-08-2021',
            name: 'Arya Dikara Bahar',
            startDate: '23-08-2021',
            endDate: '23-08-2021',
            description: 'tester izin',
            deptStatus: 'Disetujui Kepala Departemen',
            hrdStatus: 'Ditolak HRD',
          ),
          SizedBox(height: 16),
          IzinCard(
            type: 'Cuti',
            status: 'Ditolak',
            statusDate: '03-08-2021',
            name: 'Arya Dikara Bahar',
            startDate: '04-08-2021',
            endDate: '04-08-2021',
            description: 'Sakit Kepala(tester)',
            deptStatus: 'Ditolak Kepala Departemen',
            hrdStatus: 'Belum disetujui HRD',
          ),
        ],
      ),
    );
  }
}

class IzinCard extends StatelessWidget {
  final String type, status, statusDate, name, startDate, endDate, description;
  final String deptStatus, hrdStatus;

  const IzinCard({
    super.key,
    required this.type,
    required this.status,
    required this.statusDate,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.deptStatus,
    required this.hrdStatus,
  });

  Color _typeColor() {
    switch (type.toLowerCase()) {
      case 'izin':
        return Colors.green;
      case 'cuti':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _statusColor(String text) {
    if (text.toLowerCase().contains("disetujui")) {
      return Colors.green;
    } else if (text.toLowerCase().contains("ditolak")) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Jenis & Tanggal Status
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _typeColor(),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    type,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      statusDate,
                      style: const TextStyle(
                        fontSize: 12, // Ukuran dikecilkan
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      // ignore: avoid_print
                      print('Item deleted');
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              'Oleh $name',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Mulai : ', style: TextStyle(color: Colors.green)),
                Text(
                  startDate,
                  style: const TextStyle(
                    fontSize: 12, // Ukuran dikecilkan
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 16),
                const Text('Selesai : ', style: TextStyle(color: Colors.red)),
                Text(
                  endDate,
                  style: const TextStyle(
                    fontSize: 12, // Ukuran dikecilkan
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: 'Keterangan: ',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
                children: [
                  TextSpan(
                    text: description,
                    style: const TextStyle(
                        fontWeight: FontWeight.normal, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(deptStatus),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    deptStatus,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(hrdStatus),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    hrdStatus,
                    style: TextStyle(
                      color: hrdStatus.toLowerCase().contains("belum")
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
