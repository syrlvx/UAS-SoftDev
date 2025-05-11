import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:purelux/screens/detail_karyawan.dart';

class DataAdminScreen extends StatefulWidget {
  const DataAdminScreen({super.key});

  @override
  State<DataAdminScreen> createState() => _DataAdminScreenState();
}

class _DataAdminScreenState extends State<DataAdminScreen> {
  final List<Map<String, String>> dummyEmployees = [
    {
      "id": "1",
      "name": "Sherly Olivia",
      "email": "sherly@example.com",
      "position": "Frontend Developer",
    },
    {
      "id": "2",
      "name": "Raka Wijaya",
      "email": "raka@example.com",
      "position": "Backend Developer",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data Karyawan',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.black), // Black text
        ),
        backgroundColor: const Color(0xFF001F3D),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddEmployeeDialog,
            tooltip: "Tambah Karyawan",
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AbsensiPieChart(),
          const SizedBox(height: 20),
          ...dummyEmployees.map((employee) {
            return Card(
              color: Colors.white, // Set the card color to white
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(
                  employee["name"] ?? "",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.black), // Black text
                ),
                subtitle: Text(
                  "${employee["position"]} - ${employee["email"]}",
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: Colors.black), // Black text
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailKaryawanScreen(data: employee),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showAddEmployeeDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final positionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Karyawan', style: GoogleFonts.poppins()),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildInputField('Nama Lengkap', nameController),
                const SizedBox(height: 10),
                _buildInputField('Email', emailController),
                const SizedBox(height: 10),
                _buildInputField('Jabatan', positionController),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Batal', style: GoogleFonts.poppins()),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF001F3D),
                foregroundColor: Colors.white,
              ),
              child: Text('Simpan', style: GoogleFonts.poppins()),
              onPressed: () {
                setState(() {
                  dummyEmployees.add({
                    "name": nameController.text,
                    "email": emailController.text,
                    "position": positionController.text,
                  });
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
}

class AbsensiPieChart extends StatelessWidget {
  const AbsensiPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    final absensiData = [
      {"label": "Hadir", "value": 50.0, "color": Colors.blue},
      {"label": "Terlambat", "value": 15.0, "color": Colors.lightBlue},
      {"label": "Izin", "value": 0.0, "color": Colors.green},
      {"label": "Cuti", "value": 2.0, "color": Colors.orange},
      {"label": "Belum Absen", "value": 4.0, "color": Colors.red},
    ];

    return Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Selasa, 07 Januari 2023",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black, // Changed to black
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 35,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today,
                      size: 16, color: Colors.black),
                  label: Text(
                    "Kalender Absensi",
                    style:
                        GoogleFonts.poppins(fontSize: 12, color: Colors.black),
                  ),
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Text(
                    "Lihat Semua",
                    style:
                        GoogleFonts.poppins(fontSize: 12, color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(
                height: 70), // Menambahkan jarak agar Pie Chart lebih terpisah
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Pie Chart di kiri
                Expanded(
                  flex: 2,
                  child: AspectRatio(
                    aspectRatio: 1.3,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // PieChart dipindahkan ke dalam Padding biar hanya pie-nya yang geser
                        Padding(
                          padding: const EdgeInsets.only(left: 100),
                          child: PieChart(
                            PieChartData(
                              centerSpaceRadius: 50,
                              sectionsSpace: 2,
                              centerSpaceColor: Colors.white,
                              sections: absensiData
                                  .where((e) => (e['value'] as double) > 0)
                                  .map((e) => PieChartSectionData(
                                        color: e['color'] as Color,
                                        value: e['value'] as double,
                                        title: '',
                                        radius: 50,
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),

                        // Tulisan tetap center, tidak ikut padding

                        Transform.translate(
                          offset: Offset(50, 0), // Geser ke kanan 10 pixel
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Belum Absen",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "${(absensiData.firstWhere((e) => e['label'] == 'Belum Absen', orElse: () => {
                                      'value': 0
                                    })['value'] as num).toInt()}",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                    width:
                        120), // Menambahkan jarak agar label tidak terlalu dekat dengan Pie Chart

                // Label warna di kanan
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: absensiData.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: entry['color'] as Color,
                              radius: 5,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              entry['label'] as String,
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.black),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),

            // Statistik angka tetap di bawah
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: absensiData
                  .where((e) => e['label'] != null)
                  .map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e['label'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "${(e['value'] as double).toInt()}",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ]),
        ));
  }
}
