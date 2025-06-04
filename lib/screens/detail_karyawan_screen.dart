import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:purelux/screens/edit_karyawan.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class DetailKaryawanScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const DetailKaryawanScreen({super.key, required this.data});

  @override
  State<DetailKaryawanScreen> createState() => _DetailKaryawanScreenState();
}

class _DetailKaryawanScreenState extends State<DetailKaryawanScreen> {
  int hadirCount = 0;
  int izinCutiCount = 0;
  int completedTasksCount = 0;
  int terlambatCount = 0;
  int lateTasksCount = 0;
  bool isLoading = true;
  int performanceScore = 85;
  StreamSubscription? _userSubscription;
  StreamSubscription? _absensiSubscription;
  StreamSubscription? _tugasSubscription;

  // Add missing date list variables
  List<DateTime> hadirDates = [];
  List<DateTime> izinCutiDates = [];
  List<DateTime> terlambatDates = [];
  List<DateTime> completedTasksDates = [];
  List<DateTime> lateTasksDates = [];

  @override
  void initState() {
    super.initState();
    _setupStreams();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _absensiSubscription?.cancel();
    _tugasSubscription?.cancel();
    super.dispose();
  }

  void _setupStreams() {
    final String userId = widget.data['id'];
    if (userId == null) return;

    setState(() {
      isLoading = true;
    });

    // Stream for user data (performance score)
    _userSubscription = FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            performanceScore = data['score'] ?? 0;
            // Update widget.data with new values
            widget.data['username'] = data['username'];
            widget.data['email'] = data['email'];
            widget.data['role'] = data['role'];
            widget.data['notes'] = data['notes'];
            isLoading = false;
          });
        }
      }
    });

    // Stream for absensi data
    _absensiSubscription = FirebaseFirestore.instance
        .collection('absensi')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      _processAbsensiData(snapshot.docs);
    });

    // Stream for tugas data
    _tugasSubscription = FirebaseFirestore.instance
        .collection('tugas')
        .where('karyawanUid', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      _processTugasData(snapshot.docs);
    });
  }

  void _processAbsensiData(List<QueryDocumentSnapshot> docs) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    int tempHadirCount = 0;
    int tempTerlambatCount = 0;
    List<DateTime> tempHadirDates = [];
    List<DateTime> tempTerlambatDates = [];

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final tanggal = data['tanggal'] as String;
      final waktuMasuk = data['waktu_masuk'] as Timestamp;
      final waktuMasukDate = waktuMasuk.toDate();

      if (tanggal.compareTo(DateFormat('yyyy-MM-dd').format(firstDay)) >= 0 &&
          tanggal.compareTo(DateFormat('yyyy-MM-dd').format(lastDay)) <= 0) {
        tempHadirCount++;
        tempHadirDates.add(waktuMasukDate);

        if (waktuMasukDate.hour > 8 ||
            (waktuMasukDate.hour == 8 && waktuMasukDate.minute > 15)) {
          tempTerlambatCount++;
          tempTerlambatDates.add(waktuMasukDate);
        }
      }
    }

    if (mounted) {
      setState(() {
        hadirCount = tempHadirCount;
        terlambatCount = tempTerlambatCount;
        hadirDates = tempHadirDates;
        terlambatDates = tempTerlambatDates;
      });
    }
  }

  void _processTugasData(List<QueryDocumentSnapshot> docs) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final firstDayNextMonth = DateTime(now.year, now.month + 1, 1);

    int tempCompletedCount = 0;
    int tempLateCount = 0;
    List<DateTime> tempCompletedDates = [];
    List<DateTime> tempLateDates = [];

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'belum_dikerjakan';
      final timestamp = data['tanggal'] as Timestamp?;

      if (timestamp == null) continue;
      final date = timestamp.toDate();

      if (date.isAfter(firstDay) && date.isBefore(firstDayNextMonth)) {
        if (status == 'Selesai') {
          tempCompletedCount++;
          tempCompletedDates.add(date);

          if (data['isLate'] == true) {
            tempLateCount++;
            tempLateDates.add(date);
          }
        } else {
          final waktuSelesai = data['waktuSelesai'] as Timestamp;
          if (waktuSelesai.toDate().isBefore(now)) {
            tempLateCount++;
            tempLateDates.add(waktuSelesai.toDate());
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        completedTasksCount = tempCompletedCount;
        lateTasksCount = tempLateCount;
        completedTasksDates = tempCompletedDates;
        lateTasksDates = tempLateDates;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.data['username'] ?? 'Karyawan';
    String email = widget.data['email'] ?? '-';
    String position = widget.data['role'] ?? '-';
    String initials = name.isNotEmpty ? name[0] : '?';
    String? photoUrl = widget.data['foto'];
    String notes = widget.data['notes'] ?? 'Tidak ada catatan.';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF001F3D), Color(0xFFFFFFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                ],
              ),
            ),
            title: Text(
              "Detail Karyawan",
            ),
            centerTitle: true,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'edit') {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditKaryawanScreen(data: widget.data),
                      ),
                    );

                    if (result == true) {
                      setState(() {
                        isLoading = true;
                      });
                      _setupStreams();
                    }
                  } else if (value == 'delete') {
                    // Store the context before showing dialog
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);

                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        backgroundColor: Colors.white,
                        title: Text("Hapus Karyawan?",
                            style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                        content: Text(
                          "Apakah kamu yakin ingin menghapus $name?",
                          style: GoogleFonts.poppins(color: Colors.black),
                        ),
                        actions: [
                          TextButton(
                            child: Text("Batal",
                                style:
                                    GoogleFonts.poppins(color: Colors.black)),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                          TextButton(
                            child: Text("Hapus",
                                style: GoogleFonts.poppins(color: Colors.red)),
                            onPressed: () {
                              Navigator.pop(dialogContext); // Close dialog
                              deleteKaryawan(widget.data['id'], context);
                            },
                          ),
                        ],
                      ),
                    );
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blueAccent,
                    backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl == null || photoUrl.isEmpty
                        ? Text(initials,
                            style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white))
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(name,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black)),
                  Text(email,
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.grey[700])),
                  Text(position,
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.grey[700])),
                  const SizedBox(height: 20),

                  /// Penilaian Kinerja
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Penilaian Kinerja',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Skor Kinerja: $performanceScore/100",
                            style: GoogleFonts.poppins(
                                fontSize: 15, color: Colors.black)),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: performanceScore / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            performanceScore < 50
                                ? Colors.red
                                : performanceScore < 75
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),

                  /// Grafik Absensi
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Grafik Absensi:',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 50,
                        sectionsSpace: 2,
                        centerSpaceColor: Colors.white,
                        sections: [
                          PieChartSectionData(
                            color: Colors.green,
                            value: hadirCount.toDouble(),
                            title:
                                '${(hadirCount / (hadirCount + izinCutiCount + terlambatCount) * 100).toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            radius: 40,
                          ),
                          PieChartSectionData(
                            color: Colors.orange,
                            value: izinCutiCount.toDouble(),
                            title:
                                '${(izinCutiCount / (hadirCount + izinCutiCount + terlambatCount) * 100).toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            radius: 40,
                          ),
                          PieChartSectionData(
                            color: Colors.red,
                            value: terlambatCount.toDouble(),
                            title:
                                '${(terlambatCount / (hadirCount + izinCutiCount + terlambatCount) * 100).toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            radius: 40,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildInfoCard(
                    color: Colors.green,
                    title: 'Hadir',
                    subtitle: '$hadirCount Hari',
                    onTap: () => _showDateDetails(
                      context,
                      'Detail Hadir',
                      hadirDates,
                      Colors.green,
                    ),
                  ),

                  _buildInfoCard(
                    color: Colors.orange,
                    title: 'Izin & Cuti',
                    subtitle: '$izinCutiCount Hari',
                    onTap: () => _showDateDetails(
                      context,
                      'Detail Izin & Cuti',
                      izinCutiDates,
                      Colors.orange,
                    ),
                  ),

                  _buildInfoCard(
                    color: Colors.red,
                    title: 'Terlambat',
                    subtitle: '$terlambatCount Hari',
                    onTap: () => _showDateDetails(
                      context,
                      'Detail Terlambat',
                      terlambatDates,
                      Colors.red,
                    ),
                  ),

                  _buildInfoCard(
                    color: Colors.blue,
                    title: 'Tugas Selesai',
                    subtitle: '$completedTasksCount Tugas',
                    onTap: () {
                      print('completedTasksCount: $completedTasksCount');
                      print('completedTasksDates: $completedTasksDates');
                      _showDateDetails(
                        context,
                        'Tugas Selesai',
                        completedTasksDates,
                        Colors.blue,
                      );
                    },
                  ),

                  _buildInfoCard(
                    color: const Color.fromARGB(255, 235, 38, 169),
                    title: 'Tugas Terlambat',
                    subtitle: '$lateTasksCount Tugas',
                    onTap: () => _showDateDetails(
                      context,
                      'Tugas Terlambat',
                      lateTasksDates,
                      const Color.fromARGB(255, 235, 38, 169),
                    ),
                  ),

                  const SizedBox(height: 35),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Catatan: ',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(notes,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.black)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap, // tambah ini
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap, // <- ini bikin kartu bisa dipencet
        leading: CircleAvatar(backgroundColor: color, radius: 8),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _showDateDetails(BuildContext context, String title,
      List<DateTime> dates, Color titleColor) {
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
                  '$title',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: titleColor, // Ini yang berubah
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: dates.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          DateFormat('EEEE, d MMM yyyy').format(dates[index]),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                          ),
                        ),
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

  void deleteKaryawan(String id, BuildContext context) async {
    // Store the context before any async operations
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      // Cancel all subscriptions before deletion
      _userSubscription?.cancel();
      _absensiSubscription?.cancel();
      _tugasSubscription?.cancel();

      // Delete the user document
      await FirebaseFirestore.instance.collection('user').doc(id).delete();

      // Use stored context references
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Karyawan berhasil dihapus')),
      );

      // Navigate back to previous screen
      navigator.pop(true);
    } catch (e) {
      // Use stored context references
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Gagal menghapus karyawan: $e')),
      );
    }
  }

  // Add refresh method
  Future<void> refreshData() async {
    setState(() {
      isLoading = true;
    });
    _setupStreams();
  }
}
