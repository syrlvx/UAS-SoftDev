import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RekapAbsensiScreen extends StatefulWidget {
  const RekapAbsensiScreen({super.key});

  @override
  State<RekapAbsensiScreen> createState() => _RekapAbsensiScreenState();
}

class _RekapAbsensiScreenState extends State<RekapAbsensiScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;

  // Bulan & tahun pilihan (default bulan ini)
  DateTime selectedDate = DateTime.now();

  // Minggu pilihan (default minggu ini)
  int selectedWeek = 1;

  List<DateTime> tanggalHadirAll = [];
  List<DateTime> tanggalTidakHadirAll = [];
  List<DateTime> tanggalTerlambatAll = [];

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadAbsensiData();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        // Reset selection when changing tabs
        selectedDate = DateTime.now();
        selectedWeek = 1;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAbsensiData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final user = _auth.currentUser;
      if (user == null) {
        print('DEBUG: No user logged in');
        return;
      }

      print('DEBUG: Loading absensi for user: ${user.uid}');

      // Get all documents for the user
      final querySnapshot = await _firestore
          .collection('absensi')
          .where('user_id', isEqualTo: user.uid)
          .get();

      print('DEBUG: Total documents found: ${querySnapshot.docs.length}');

      // Reset lists
      tanggalHadirAll = [];
      tanggalTidakHadirAll = [];
      tanggalTerlambatAll = [];

      // Get all dates in the current month
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final today =
          DateTime(now.year, now.month, now.day); // Normalize to start of day

      print('DEBUG: First day of month: $firstDayOfMonth');
      print('DEBUG: Today: $today');

      // Create a set of all days in the month up to today
      Set<DateTime> allWorkdays = {};
      var currentDate = firstDayOfMonth;
      while (currentDate.isBefore(today.add(const Duration(days: 1)))) {
        allWorkdays.add(currentDate);
        currentDate = currentDate.add(const Duration(days: 1));
      }

      print('DEBUG: Total days until today: ${allWorkdays.length}');
      print('DEBUG: Days: ${allWorkdays.map((d) => d.day).toList()}');

      // Create a set of dates that have attendance records
      Set<DateTime> datesWithRecords = {};

      // Process each document
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final tanggal = (data['tanggal'] as String).split('-');
        final date = DateTime(
          int.parse(tanggal[0]), // year
          int.parse(tanggal[1]), // month
          int.parse(tanggal[2]), // day
        );

        datesWithRecords.add(date);
        print('DEBUG: Processing date: $date');

        // Check if user was present
        if (data['waktu_masuk'] != null) {
          final waktuMasuk = (data['waktu_masuk'] as Timestamp).toDate();
          final jamMasuk = waktuMasuk.hour * 60 + waktuMasuk.minute;

          if (jamMasuk > 8 * 60 + 15) {
            // After 8:15 AM
            tanggalTerlambatAll.add(date);
            print('DEBUG: Added to terlambat: $date');
          } else {
            tanggalHadirAll.add(date);
            print('DEBUG: Added to hadir: $date');
          }
        } else {
          tanggalTidakHadirAll.add(date);
          print('DEBUG: Added to tidak hadir: $date');
        }
      }

      // Add missing dates as "Tidak Hadir"
      for (var workday in allWorkdays) {
        if (!datesWithRecords.contains(workday)) {
          tanggalTidakHadirAll.add(workday);
          print('DEBUG: Added missing date to tidak hadir: $workday');
        }
      }

      print('DEBUG: Total hadir: ${tanggalHadirAll.length}');
      print('DEBUG: Total terlambat: ${tanggalTerlambatAll.length}');
      print('DEBUG: Total tidak hadir: ${tanggalTidakHadirAll.length}');
      print(
          'DEBUG: Total all: ${tanggalHadirAll.length + tanggalTerlambatAll.length + tanggalTidakHadirAll.length}');

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading absensi data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fungsi untuk mendapatkan minggu dalam bulan
  int getWeekOfMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    final dayOfMonth = date.day;
    return ((dayOfMonth + firstWeekday - 1) / 7).ceil();
  }

  // Fungsi untuk mendapatkan tanggal awal dan akhir minggu
  DateTimeRange getWeekRange(DateTime date) {
    final firstDayOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
    return DateTimeRange(start: firstDayOfWeek, end: lastDayOfWeek);
  }

  // Fungsi untuk mendapatkan nama bulan
  String getMonthName(DateTime date) {
    return months[date.month - 1];
  }

  // Fungsi untuk filter tanggal sesuai bulan & tahun yg dipilih
  List<DateTime> filterTanggalByMonthYear(List<DateTime> dates) {
    return dates
        .where((date) =>
            date.month == selectedDate.month && date.year == selectedDate.year)
        .toList();
  }

  // Fungsi untuk filter tanggal sesuai minggu yg dipilih
  List<DateTime> filterTanggalByWeek(List<DateTime> dates) {
    final weekRange = getWeekRange(selectedDate);
    return dates
        .where((date) =>
            date.isAfter(weekRange.start.subtract(const Duration(days: 1))) &&
            date.isBefore(weekRange.end.add(const Duration(days: 1))))
        .toList();
  }

  int get hadir {
    switch (_tabController.index) {
      case 0: // Bulanan
        return filterTanggalByMonthYear(tanggalHadirAll).length;
      case 1: // Mingguan
        return filterTanggalByWeek(tanggalHadirAll).length;
      default:
        return 0;
    }
  }

  int get tidakHadir {
    switch (_tabController.index) {
      case 0:
        return filterTanggalByMonthYear(tanggalTidakHadirAll).length;
      case 1:
        return filterTanggalByWeek(tanggalTidakHadirAll).length;
      default:
        return 0;
    }
  }

  int get terlambat {
    switch (_tabController.index) {
      case 0:
        return filterTanggalByMonthYear(tanggalTerlambatAll).length;
      case 1:
        return filterTanggalByWeek(tanggalTerlambatAll).length;
      default:
        return 0;
    }
  }

  List<String> get tanggalHadir {
    switch (_tabController.index) {
      case 0:
        return filterTanggalByMonthYear(tanggalHadirAll)
            .map((e) => formatTanggal(e))
            .toList();
      case 1:
        return filterTanggalByWeek(tanggalHadirAll)
            .map((e) => formatTanggal(e))
            .toList();
      default:
        return [];
    }
  }

  List<String> get tanggalTidakHadir {
    switch (_tabController.index) {
      case 0:
        return filterTanggalByMonthYear(tanggalTidakHadirAll)
            .map((e) => formatTanggal(e))
            .toList();
      case 1:
        return filterTanggalByWeek(tanggalTidakHadirAll)
            .map((e) => formatTanggal(e))
            .toList();
      default:
        return [];
    }
  }

  List<String> get tanggalTerlambat {
    switch (_tabController.index) {
      case 0:
        return filterTanggalByMonthYear(tanggalTerlambatAll)
            .map((e) => formatTanggal(e))
            .toList();
      case 1:
        return filterTanggalByWeek(tanggalTerlambatAll)
            .map((e) => formatTanggal(e))
            .toList();
      default:
        return [];
    }
  }

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
        titleStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: tidakHadir.toDouble(),
        title: '${((tidakHadir / total) * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: terlambat.toDouble(),
        title: '${((terlambat / total) * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      )
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      buildRekapContent("Rekap Bulanan"),
                      buildRekapContent("Rekap Mingguan"),
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
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Navigation controls based on tab
          if (_tabController.index == 0) // Bulanan
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      selectedDate = DateTime(
                        selectedDate.year,
                        selectedDate.month - 1,
                        1,
                      );
                    });
                  },
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF001F3D),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${getMonthName(selectedDate)} ${selectedDate.year}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      selectedDate = DateTime(
                        selectedDate.year,
                        selectedDate.month + 1,
                        1,
                      );
                    });
                  },
                ),
              ],
            )
          else // Mingguan
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      selectedDate =
                          selectedDate.subtract(const Duration(days: 7));
                    });
                  },
                ),
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF001F3D),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Minggu ${getWeekOfMonth(selectedDate)} - ${formatTanggal(getWeekRange(selectedDate).start)} s/d ${formatTanggal(getWeekRange(selectedDate).end)}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      selectedDate = selectedDate.add(const Duration(days: 7));
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
        title: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16, // Ukuran font 16 untuk title
          ),
        ),
        trailing: Text(
          "$value Hari",
          style: GoogleFonts.poppins(
            fontSize: 13, // Mengurangi ukuran font untuk "X Hari"
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
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
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: tanggalList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(
                            tanggalList[index],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                            ),
                          ));
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
