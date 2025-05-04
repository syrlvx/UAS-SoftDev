import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:purelux/screens/tambah_tugas.dart';
import 'package:intl/intl.dart';

class TugasAdminScreen extends StatefulWidget {
  const TugasAdminScreen({Key? key}) : super(key: key);

  @override
  _TugasAdminScreenState createState() => _TugasAdminScreenState();
}

class _TugasAdminScreenState extends State<TugasAdminScreen> {
  int selectedDateIndex = 0;

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
                    const Text("My Task",
                        style: TextStyle(
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
                              builder: (context) => TambahTugasScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Text("Today",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: List.generate(5, (index) {
                    bool isSelected = selectedDateIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDateIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color.fromARGB(255, 149, 212, 240)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text("0${index + 1}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            Text("MTWTF"[index],
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    );
                  }),
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
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("Tidak ada tugas."));
                      }

                      return ListView(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          List<String> jenisTugasList =
                              List<String>.from(data['jenisTugas'] ?? []);
                          Timestamp timestampTanggal = data['tanggal'];
                          Timestamp timestampWaktuMulai = data['waktuMulai'];

                          // Convert Timestamp to DateTime
                          DateTime deadlineDate = timestampTanggal.toDate();
                          DateTime startTime = timestampWaktuMulai.toDate();

                          // Format tanggal dan waktu
                          String formattedDeadline =
                              DateFormat('d MMM yyyy').format(deadlineDate);
                          String formattedStartTime =
                              DateFormat('HH:mm').format(startTime);

                          return TaskCard(
                            employeeName: data['karyawanNama'] ?? 'Unknown',
                            jenisTugasList: jenisTugasList,
                            deadline: formattedDeadline,
                            deadlineTime: formattedStartTime,
                            status: data['status'] ?? 'Pending',
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

  const TaskCard({
    Key? key,
    required this.employeeName,
    required this.jenisTugasList,
    required this.deadline,
    required this.deadlineTime,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'Selesai' ? Colors.green : Colors.orange;
    IconData statusIcon =
        status == 'Selesai' ? Icons.check : Icons.hourglass_bottom;
    String statusLabel = status == 'Selesai' ? 'ACC' : 'Pending';

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8, // Increased elevation for a more prominent shadow
      shadowColor: Colors.black45, // Darker shadow for better visibility
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -10),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employeeName,
                      style: const TextStyle(
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
                                  style: const TextStyle(
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
                            size: 14, color: Colors.black45),
                        const SizedBox(width: 4),
                        Text(
                          deadlineTime,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
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
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: statusColor,
                    child: Icon(statusIcon, size: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
