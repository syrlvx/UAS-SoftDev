import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:purelux/screens/edit_karyawan.dart';
import 'package:intl/intl.dart';

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

  // Add missing date list variables
  List<DateTime> hadirDates = [];
  List<DateTime> izinCutiDates = [];
  List<DateTime> terlambatDates = [];
  List<DateTime> completedTasksDates = [];
  List<DateTime> lateTasksDates = [];

  @override
  void initState() {
    super.initState();
    _loadAbsensiData();
    _loadCompletedTasks();
    _loadLateTasks();
    _loadPerformanceScore();
  }

  Future<void> _loadAbsensiData() async {
    try {
      // Get current month's date range
      final now = DateTime.now();
      final firstDay = DateTime(now.year, now.month, 1);
      final lastDay = DateTime(now.year, now.month + 1, 0);

      // Format dates for query
      final formattedFirstDay = DateFormat('yyyy-MM-dd').format(firstDay);
      final formattedLastDay = DateFormat('yyyy-MM-dd').format(lastDay);

      print('Date range: $formattedFirstDay to $formattedLastDay');
      print('User ID being checked: ${widget.data['id']}');

      // Full user data for debugging
      print('Full user data: ${widget.data}');

      // First, let's check what's in the pengajuan collection without filters
      final allPengajuan =
          await FirebaseFirestore.instance.collection('pengajuan').get();

      print(
          'Total pengajuan documents in collection: ${allPengajuan.docs.length}');
      if (allPengajuan.docs.isNotEmpty) {
        print('Sample pengajuan document data:');
        final sampleDoc = allPengajuan.docs.first.data();
        print('userId: ${sampleDoc['userId']}');
        print('status: ${sampleDoc['status']}');
        print('jenis: ${sampleDoc['jenis']}');
      }

      // Query pengajuan collection for approved izin/cuti
      final String userId = widget.data['id'];
      if (userId != null) {
        // Let's try querying without the status filter first
        final QuerySnapshot pengajuanSnapshot = await FirebaseFirestore.instance
            .collection('pengajuan')
            .where('userId', isEqualTo: userId)
            .get();

        print(
            'Found ${pengajuanSnapshot.docs.length} pengajuan documents for userId: $userId');

        // If we found any documents, let's see their status
        if (pengajuanSnapshot.docs.isNotEmpty) {
          print('Pengajuan documents found for this user:');
          for (var doc in pengajuanSnapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            print('Status: ${data['status']}, Jenis: ${data['jenis']}');
          }
        }

        // Count approved izin/cuti within current month
        int tempIzinCutiCount = 0;
        List<DateTime> tempIzinCutiDates = [];
        for (var doc in pengajuanSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['tanggal'] != null) {
            final tanggal = (data['tanggal'] as Timestamp).toDate();
            final formattedTanggal = DateFormat('yyyy-MM-dd').format(tanggal);
            print(
                'Document date: $formattedTanggal, jenis: ${data['jenis']}, status: ${data['status']}');

            // Only count if within current month and is either izin or cuti
            if (formattedTanggal.compareTo(formattedFirstDay) >= 0 &&
                formattedTanggal.compareTo(formattedLastDay) <= 0 &&
                (data['jenis'] == 'izin' || data['jenis'] == 'cuti')) {
              tempIzinCutiCount++;
              tempIzinCutiDates.add(tanggal);
              print('Counted izin/cuti! Current count: $tempIzinCutiCount');
            }
          }
        }

        // Query absensi collection
        final QuerySnapshot absensiSnapshot = await FirebaseFirestore.instance
            .collection('absensi')
            .where('user_id', isEqualTo: userId)
            .get();

        print('Found ${absensiSnapshot.docs.length} absensi documents');

        // Count attendance and late attendance within current month
        int tempHadirCount = 0;
        int tempTerlambatCount = 0;
        List<DateTime> tempHadirDates = [];
        List<DateTime> tempTerlambatDates = [];
        for (var doc in absensiSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final tanggal = data['tanggal'] as String;
          final waktuMasuk = data['waktu_masuk'] as Timestamp;
          final waktuMasukDate = waktuMasuk.toDate();
          print(
              'Checking absensi date: $tanggal, waktu: ${waktuMasukDate.hour}:${waktuMasukDate.minute}');

          // Only count if within current month
          if (tanggal.compareTo(formattedFirstDay) >= 0 &&
              tanggal.compareTo(formattedLastDay) <= 0) {
            tempHadirCount++;
            tempHadirDates.add(waktuMasukDate);

            // Check if late (after 8:15 AM)
            if (waktuMasukDate.hour > 8 ||
                (waktuMasukDate.hour == 8 && waktuMasukDate.minute > 15)) {
              tempTerlambatCount++;
              tempTerlambatDates.add(waktuMasukDate);
              print(
                  'Counted late attendance! Current count: $tempTerlambatCount');
            }

            print('Counted attendance! Current count: $tempHadirCount');
          }
        }

        if (mounted) {
          setState(() {
            hadirCount = tempHadirCount;
            izinCutiCount = tempIzinCutiCount;
            terlambatCount = tempTerlambatCount;
            hadirDates = tempHadirDates;
            izinCutiDates = tempIzinCutiDates;
            terlambatDates = tempTerlambatDates;
            isLoading = false;
          });
        }
      } else {
        print('Error: userId is null');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading absensi data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCompletedTasks() async {
    try {
      final String userId = widget.data['id'];
      if (userId != null) {
        final QuerySnapshot tugasSnapshot = await FirebaseFirestore.instance
            .collection('tugas')
            .where('karyawanUid', isEqualTo: userId)
            .where('status', isEqualTo: 'Selesai')
            .get();

        List<DateTime> tempCompletedTasksDates = [];
        for (var doc in tugasSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['tanggal'] != null) {
            tempCompletedTasksDates
                .add((data['tanggal'] as Timestamp).toDate());
          }
        }

        if (mounted) {
          setState(() {
            completedTasksCount = tugasSnapshot.docs.length;
            completedTasksDates = tempCompletedTasksDates;
          });
        }
      }
    } catch (e) {
      print('Error loading completed tasks: $e');
    }
  }

  Future<void> _loadLateTasks() async {
    try {
      final String userId = widget.data['id'];
      if (userId != null) {
        // Get current month's date range
        final now = DateTime.now();
        final firstDay = DateTime(now.year, now.month, 1);
        final lastDay = DateTime(now.year, now.month + 1, 0);

        // Query all tasks for this month
        final QuerySnapshot tugasSnapshot = await FirebaseFirestore.instance
            .collection('tugas')
            .where('karyawanUid', isEqualTo: userId)
            .where('tanggal',
                isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay))
            .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(lastDay))
            .get();

        int tempLateCount = 0;
        List<DateTime> tempLateTasksDates = [];
        for (var doc in tugasSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] as String? ?? 'belum_dikerjakan';

          // Count as late if:
          // 1. Task is completed and was completed late (isLate is true)
          // 2. Task is not completed and deadline has passed
          if (status == 'Selesai') {
            // Check if the task was submitted late
            if (data['isLate'] == true) {
              tempLateCount++;
              if (data['tanggal'] != null) {
                tempLateTasksDates.add((data['tanggal'] as Timestamp).toDate());
              }
            }
          } else {
            // For incomplete tasks, check if deadline has passed
            final waktuSelesai = data['waktuSelesai'] as Timestamp;
            if (waktuSelesai.toDate().isBefore(now)) {
              tempLateCount++;
              tempLateTasksDates.add(waktuSelesai.toDate());
            }
          }
        }

        if (mounted) {
          setState(() {
            lateTasksCount = tempLateCount;
            lateTasksDates = tempLateTasksDates;
          });
        }
      }
    } catch (e) {
      print('Error loading late tasks: $e');
    }
  }

  Future<void> _loadPerformanceScore() async {
    try {
      final String userId = widget.data['id'];
      if (userId != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(userId)
            .get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data() as Map<String, dynamic>;
          if (mounted) {
            setState(() {
              performanceScore = data['score'] ?? 0;
            });
          }
        }
      }
    } catch (e) {
      print('Error loading performance score: $e');
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
            automaticallyImplyLeading: false, // Supaya leading manual dipakai
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
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditKaryawanScreen(data: widget.data),
                      ),
                    );
                  } else if (value == 'delete') {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        title: Text("Hapus Karyawan?",
                            style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                        content: Text(
                          "Apakah kamu yakin ingin menghapus ${widget.data['name']}?",
                          style: GoogleFonts.poppins(color: Colors.black),
                        ),
                        actions: [
                          TextButton(
                            child: Text("Batal",
                                style:
                                    GoogleFonts.poppins(color: Colors.black)),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: Text("Hapus",
                                style: GoogleFonts.poppins(color: Colors.red)),
                            onPressed: () {
                              deleteKaryawan(widget.data['id'], context);
                              Navigator.pop(context);
                              Navigator.pop(context);
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
                    onTap: () => _showDateDetails(
                      context,
                      'Tugas Selesai',
                      completedTasksDates,
                      Colors.blue,
                    ),
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
    try {
      await FirebaseFirestore.instance.collection('karyawan').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Karyawan berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus karyawan: $e')),
      );
    }
  }
}
