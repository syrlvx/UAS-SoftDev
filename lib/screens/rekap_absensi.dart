import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // butuh package intl untuk format tanggal

class RekapAbsensiScreen extends StatefulWidget {
  const RekapAbsensiScreen({super.key});

  @override
  State<RekapAbsensiScreen> createState() => _RekapAbsensiScreenState();
}

class _RekapAbsensiScreenState extends State<RekapAbsensiScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Bulan & tahun pilihan (default Mei 2025)
  String selectedMonth = 'Mei';
  int selectedYear = 2025;

  final List<String> months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  final List<int> years = [2023, 2024, 2025, 2026];

  // Data tanggal dalam bentuk DateTime
  final List<DateTime> tanggalHadirAll = [
    DateTime(2025, 5, 1),
    DateTime(2025, 5, 2),
    DateTime(2025, 5, 3),
    DateTime(2025, 5, 6),
    DateTime(2025, 5, 7),
    DateTime(2025, 5, 8),
    DateTime(2025, 5, 9),
    DateTime(2025, 5, 10),
    DateTime(2025, 5, 13),
    DateTime(2025, 5, 14),
    DateTime(2025, 5, 15),
    DateTime(2025, 5, 16),
    DateTime(2025, 5, 17),
    DateTime(2025, 5, 20),
    DateTime(2025, 5, 21),
    DateTime(2025, 5, 22),
    DateTime(2025, 5, 23),
    DateTime(2025, 5, 24),
  ];

  final List<DateTime> tanggalTidakHadirAll = [
    DateTime(2025, 5, 5),
    DateTime(2025, 5, 19)
  ];

  final List<DateTime> tanggalTerlambatAll = [
    DateTime(2025, 5, 4),
    DateTime(2025, 5, 11),
    DateTime(2025, 5, 18)
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  // Fungsi untuk filter tanggal sesuai bulan & tahun yg dipilih
  List<DateTime> filterTanggalByMonthYear(List<DateTime> dates) {
    int monthIndex = months.indexOf(selectedMonth) + 1; // bulan dari 1-12
    return dates
        .where((date) => date.month == monthIndex && date.year == selectedYear)
        .toList();
  }

  int get hadir => filterTanggalByMonthYear(tanggalHadirAll).length;
  int get tidakHadir => filterTanggalByMonthYear(tanggalTidakHadirAll).length;
  int get terlambat => filterTanggalByMonthYear(tanggalTerlambatAll).length;

  List<String> get tanggalHadir => filterTanggalByMonthYear(tanggalHadirAll)
      .map((e) => formatTanggal(e))
      .toList();

  List<String> get tanggalTidakHadir =>
      filterTanggalByMonthYear(tanggalTidakHadirAll)
          .map((e) => formatTanggal(e))
          .toList();

  List<String> get tanggalTerlambat =>
      filterTanggalByMonthYear(tanggalTerlambatAll)
          .map((e) => formatTanggal(e))
          .toList();

  // Format tanggal menjadi "d MMMM yyyy" (contoh: 1 Mei 2025)
  String formatTanggal(DateTime date) {
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  List<PieChartSectionData> showingSections() {
    final total = hadir + tidakHadir + terlambat;
    if (total == 0) return [];

    return [
      PieChartSectionData(
        color: Colors.green,
        value: hadir.toDouble(),
        title: '${((hadir / total) * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: tidakHadir.toDouble(),
        title: '${((tidakHadir / total) * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: terlambat.toDouble(),
        title: '${((terlambat / total) * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }

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
          centerTitle: true,
          title: const Text(
            'Rekap Absensi',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF001F3D), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color.fromARGB(255, 127, 157, 195),
              labelColor: const Color.fromARGB(255, 127, 157, 195),
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: "Bulanan"),
                Tab(text: "Mingguan"),
                Tab(text: "Harian"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildRekapContent("Rekap Bulanan"),
                buildRekapContent("Rekap Mingguan"),
                buildRekapContent("Rekap Harian"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRekapContent(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Dropdown bulan & tahun
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: selectedMonth,
                items: months.map((String month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text(month),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMonth = value!;
                  });
                },
              ),
              const SizedBox(width: 20),
              DropdownButton<int>(
                value: selectedYear,
                items: years.map((int year) {
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(year.toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedYear = value!;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 30),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: showingSections(),
                centerSpaceRadius: 40,
                sectionsSpace: 3,
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildAbsensiTile(
              "Hadir", hadir, Colors.green, Icons.check_circle, tanggalHadir),
          _buildAbsensiTile("Tidak Hadir", tidakHadir, Colors.red, Icons.cancel,
              tanggalTidakHadir),
          _buildAbsensiTile("Terlambat", terlambat, Colors.orange,
              Icons.access_time, tanggalTerlambat),
        ],
      ),
    );
  }

  Widget _buildAbsensiTile(
    String label,
    int value,
    Color color,
    IconData icon,
    List<String> tanggalList,
  ) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(label),
        trailing: Text("$value Hari",
            style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        onTap: () {
          _showTanggalBottomSheet(label, tanggalList, color);
        },
      ),
    );
  }

  void _showTanggalBottomSheet(
      String title, List<String> tanggalList, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.5,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$title - Detail Tanggal',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: tanggalList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(tanggalList[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
