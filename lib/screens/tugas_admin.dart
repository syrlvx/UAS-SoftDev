import 'package:flutter/material.dart';
import 'package:purelux/screens/tambah_tugas.dart';

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
            begin: Alignment.topCenter, // Mulai dari bagian atas
            end: Alignment.bottomCenter, // Berakhir di bagian bawah
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
                            fontSize: 28, fontWeight: FontWeight.bold)),
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
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
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
                                    fontWeight: FontWeight.bold)),
                            Text("MTWTF"[index]),
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
                  child: ListView(
                    children: const [
                      TaskCard(
                        title: 'Check mail',
                        description: 'Write to the manager',
                        time: '',
                        icon: Icons.mail_outline,
                      ),
                    ],
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
  final String title;
  final String description;
  final String time;
  final IconData? icon;

  const TaskCard({
    Key? key,
    required this.title,
    required this.description,
    required this.time,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (icon != null) Icon(icon, color: Colors.blue, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
