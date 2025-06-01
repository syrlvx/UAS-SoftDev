import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purelux/screens/tambah_tugas.dart';
import 'package:intl/intl.dart';

class TugasAdminScreen extends StatefulWidget {
  const TugasAdminScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TugasAdminScreenState createState() => _TugasAdminScreenState();
}

class _TugasAdminScreenState extends State<TugasAdminScreen> {
  int selectedDateIndex = 0;
  late List<DateTime> dateList;

  @override
  void initState() {
    super.initState();
    _initializeDates();
  }

  void _initializeDates() {
    final now = DateTime.now();
    dateList = List.generate(7, (index) {
      return now.add(Duration(days: index));
    });
  }

  String _getDayName(DateTime date) {
    return DateFormat('E').format(date).substring(0, 1);
  }

  String _getFormattedDate(DateTime date) {
    return DateFormat('dd').format(date);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF001F3D), // Biru navy gelap
              Color(0xFFFFFFFF), // Putih
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("My Task",
                        style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    IconButton(
                      icon: const Icon(Icons.add_circle,
                          size: 32, color: Color.fromARGB(221, 255, 255, 255)),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TambahTugasScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
                  children: [
                    if (_isToday(dateList[selectedDateIndex]))
                      Text(
                        "Today,",
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('d MMM yyyy')
                          .format(dateList[selectedDateIndex]),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(7, (index) {
                      bool isSelected = selectedDateIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDateIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color.fromARGB(255, 149, 212, 240)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getFormattedDate(dateList[index]),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 15, // ukuran font 14
                                ),
                              ),
                              Text(_getDayName(dateList[index]),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 15,
                                  )),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('tugas')
                        .where('tanggal',
                            isGreaterThanOrEqualTo: Timestamp.fromDate(
                              DateTime(
                                dateList[selectedDateIndex].year,
                                dateList[selectedDateIndex].month,
                                dateList[selectedDateIndex].day,
                                0,
                                0,
                                0,
                              ),
                            ))
                        .where('tanggal',
                            isLessThan: Timestamp.fromDate(
                              DateTime(
                                dateList[selectedDateIndex].year,
                                dateList[selectedDateIndex].month,
                                dateList[selectedDateIndex].day,
                                23,
                                59,
                                59,
                              ),
                            ))
                        .orderBy('tanggal', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.task_alt,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Tidak ada tugas untuk tanggal ini",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          List<String> jenisTugasList =
                              List<String>.from(data['jenisTugas'] ?? []);
                          Timestamp timestampTanggal = data['tanggal'];
                          Timestamp timestampWaktuMulai = data['waktuMulai'];
                          Timestamp timestampWaktuSelesai =
                              data['waktuSelesai'];

                          DateTime deadlineDate = timestampTanggal.toDate();
                          DateTime startTime = timestampWaktuMulai.toDate();
                          DateTime waktuSelesaiDate =
                              timestampWaktuSelesai.toDate();

                          if (deadlineDate.year !=
                                  dateList[selectedDateIndex].year ||
                              deadlineDate.month !=
                                  dateList[selectedDateIndex].month ||
                              deadlineDate.day !=
                                  dateList[selectedDateIndex].day) {
                            return const SizedBox.shrink();
                          }

                          String formattedDeadline =
                              DateFormat('d MMM yyyy').format(deadlineDate);
                          String formattedStartTime =
                              DateFormat('HH:mm').format(startTime);
                          String formattedEndTime =
                              DateFormat('HH:mm').format(waktuSelesaiDate);

                          bool isLate =
                              waktuSelesaiDate.isBefore(DateTime.now()) &&
                                  (data['status'] != 'Selesai');

                          return TaskCard(
                            employeeName: data['karyawanNama'] ?? 'Unknown',
                            jenisTugasList: jenisTugasList,
                            deadline: formattedDeadline,
                            deadlineTime: formattedEndTime,
                            status: data['status'] ?? 'Pending',
                            isLate: isLate,
                            isLateForSelesai:
                                waktuSelesaiDate.isBefore(DateTime.now()),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String employeeName;
  final List<String> jenisTugasList;
  final String deadline;
  final String deadlineTime;
  final String status;
  final bool isLate;
  final bool isLateForSelesai;

  const TaskCard({
    super.key,
    required this.employeeName,
    required this.jenisTugasList,
    required this.deadline,
    required this.deadlineTime,
    required this.status,
    required this.isLate,
    required this.isLateForSelesai,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'Selesai' ? Colors.green : Colors.orange;
    IconData statusIcon =
        status == 'Selesai' ? Icons.check : Icons.hourglass_bottom;
    String statusLabel = status == 'Selesai' ? 'Selesai' : 'Pending';

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      shadowColor: Colors.black45,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (status != 'Selesai') ...[
                Column(
                  children: [
                    CircleAvatar(
                      radius: 21,
                      backgroundColor: statusColor,
                      child: Icon(statusIcon, size: 20, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isLate)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Terlambat',
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employeeName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: jenisTugasList.map((jenisTugas) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.check_box_outlined,
                                  size: 16, color: Colors.black54),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  jenisTugas,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 16, color: Color(0xFF001F3D)),
                        const SizedBox(width: 4),
                        Text(
                          deadlineTime,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Color(0xFF001F3D),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    deadline,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (status == 'Selesai') ...[
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: statusColor,
                      child: Icon(statusIcon, size: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isLateForSelesai)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Terlambat',
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
