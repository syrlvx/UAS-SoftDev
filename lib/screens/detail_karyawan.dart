import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class DetailKaryawanScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const DetailKaryawanScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    String name = data['name'] ?? 'Karyawan';
    String email = data['email'] ?? '-';
    String position = data['position'] ?? '-';
    String initials = name.isNotEmpty ? name[0] : '?';
    int performanceScore = 85;

    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Karyawan", style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF001F3D),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blueAccent,
              child: Text(
                initials,
                style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(name,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 20),
                textAlign: TextAlign.center),
            Text(email,
                style:
                    GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                textAlign: TextAlign.center),
            Text(position,
                style:
                    GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Penilaian Kinerja',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Skor Kinerja: $performanceScore/100",
                      style: GoogleFonts.poppins(fontSize: 14)),
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
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Rekap Kinerja:',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 10),
            _buildInfoCard(
                color: Colors.green,
                title: 'Absensi Hadir',
                subtitle: '8 Hari'),
            _buildInfoCard(
                color: Colors.orange, title: 'Izin & Cuti', subtitle: '2 Hari'),
            _buildInfoCard(
                color: Colors.red, title: 'Terlambat', subtitle: '2 Hari'),
            _buildInfoCard(
                color: Colors.blue,
                title: 'Tugas Selesai',
                subtitle: '5 Tugas'),
            _buildInfoCard(
                color: Colors.grey,
                title: 'Tugas Tidak Tepat Waktu',
                subtitle: '1 Tugas'),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Grafik Absensi:',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(sections: [
                  PieChartSectionData(
                      color: Colors.green, value: 8, title: 'Hadir'),
                  PieChartSectionData(
                      color: Colors.orange, value: 2, title: 'Izin/Cuti'),
                  PieChartSectionData(
                      color: Colors.red, value: 2, title: 'Terlambat'),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Grafik Performa Harian:',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = [
                            'Sen',
                            'Sel',
                            'Rab',
                            'Kam',
                            'Jum',
                            'Sab',
                            'Min'
                          ];
                          return Text(days[value.toInt() % 7],
                              style: GoogleFonts.poppins(fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      spots: [
                        FlSpot(0, 75),
                        FlSpot(1, 80),
                        FlSpot(2, 85),
                        FlSpot(3, 90),
                        FlSpot(4, 70),
                        FlSpot(5, 60),
                        FlSpot(6, 88),
                      ],
                      barWidth: 3,
                      color: Colors.blueAccent,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Tugas Diselesaikan per Bulan:',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 10,
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(toY: 6, color: Colors.green)
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(toY: 7, color: Colors.orange)
                    ]),
                    BarChartGroupData(
                        x: 2,
                        barRods: [BarChartRodData(toY: 5, color: Colors.red)]),
                    BarChartGroupData(
                        x: 3,
                        barRods: [BarChartRodData(toY: 8, color: Colors.blue)]),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const labels = ['Jan', 'Feb', 'Mar', 'Apr'];
                          return Text(labels[value.toInt()],
                              style: GoogleFonts.poppins(fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Catatan:',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 6),
            Text(
                'Perlu meningkatkan ketepatan waktu dalam menyelesaikan tugas.',
                style: GoogleFonts.poppins(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFFFF0F3),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, radius: 8),
        title: Text(title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        trailing: Text(subtitle, style: GoogleFonts.poppins(fontSize: 13)),
      ),
    );
  }
}
