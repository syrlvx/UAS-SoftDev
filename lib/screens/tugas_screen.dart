import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:purelux/widgets/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TugasScreen extends StatefulWidget {
  const TugasScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TugasScreenState createState() => _TugasScreenState();
}

class _TugasScreenState extends State<TugasScreen> {
  int selectedDateIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001F3D), Color(0xFFFFFFFF)],
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: SizedBox(
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const BottomNavBar()),
                            );
                          },
                        ),
                      ),
                      const Center(
                        child: Text(
                          "My Task",
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
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
                        topRight: Radius.circular(30)),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('tugas')
                        .where('karyawanUid', isEqualTo: currentUser?.uid)
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

                          DateTime deadlineDate = timestampTanggal.toDate();
                          DateTime startTime = timestampWaktuMulai.toDate();

                          String formattedDeadline =
                              DateFormat('d MMM yyyy').format(deadlineDate);
                          String formattedStartTime =
                              DateFormat('HH:mm').format(startTime);

                          return TaskCard(
                            docId: doc.id,
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
  final String docId;
  final String employeeName;
  final List<String> jenisTugasList;
  final String deadline;
  final String deadlineTime;
  final String status;

  const TaskCard({
    super.key,
    required this.docId,
    required this.employeeName,
    required this.jenisTugasList,
    required this.deadline,
    required this.deadlineTime,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'Selesai' ? Colors.green : Colors.blue;
    IconData statusIcon =
        status == 'Selesai' ? Icons.check_circle : Icons.assignment_turned_in;
    String statusLabel = status == 'Selesai' ? 'Selesai' : 'Tugas Aktif';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      shadowColor: Colors.black45,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -10))
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
                    Text(statusLabel,
                        style: TextStyle(
                            fontSize: 11,
                            color: statusColor,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(employeeName,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black)),
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
                                      fontSize: 14, color: Colors.black87),
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
                        Text(deadlineTime,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(deadline,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 8),
                  if (status == 'Selesai') ...[
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: statusColor,
                      child: Icon(statusIcon, size: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(statusLabel,
                        style: TextStyle(
                            fontSize: 11,
                            color: statusColor,
                            fontWeight: FontWeight.bold)),
                  ],
                  const SizedBox(height: 8),
                  if (status != 'Selesai')
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('tugas')
                            .doc(docId)
                            .update({
                          'status': 'Selesai',
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        textStyle: const TextStyle(fontSize: 12),
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        'Selesaikan',
                        style: TextStyle(color: Colors.white),
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
