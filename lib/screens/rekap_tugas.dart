import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class RekapTugasScreen extends StatefulWidget {
  const RekapTugasScreen({super.key});

  @override
  State<RekapTugasScreen> createState() => _RekapTugasScreenState();
}

class _RekapTugasScreenState extends State<RekapTugasScreen> {
  final Map<String, List<Map<String, dynamic>>> dummyDataPerMonth = {
    '2025-05': [
      {
        'namaTugas': 'Tugas A',
        'tanggal': DateTime(2025, 5, 3),
        'status': 'Selesai'
      },
      {
        'namaTugas': 'Tugas B',
        'tanggal': DateTime(2025, 5, 15),
        'status': 'Pending'
      },
      {
        'namaTugas': 'Tugas C',
        'tanggal': DateTime(2025, 5, 20),
        'status': 'Selesai'
      },
      {
        'namaTugas': 'Tugas D',
        'tanggal': DateTime(2025, 5, 25),
        'status': 'Terlambat'
      },
    ],
    '2025-04': [
      {
        'namaTugas': 'Tugas X',
        'tanggal': DateTime(2025, 4, 10),
        'status': 'Selesai'
      },
      {
        'namaTugas': 'Tugas Y',
        'tanggal': DateTime(2025, 4, 18),
        'status': 'Pending'
      },
    ],
  };

  late DateTime _selectedDate;
  List<Map<String, dynamic>> _tasks = [];
  Map<String, int> _taskStatusCount = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadData();
  }

  void _loadData() {
    final key =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}';
    final tasks = dummyDataPerMonth[key] ?? [];

    Map<String, int> counts = {};
    for (var tugas in tasks) {
      String status = tugas['status'] ?? 'Pending';
      counts[status] = (counts[status] ?? 0) + 1;
    }

    setState(() {
      _tasks = tasks;
      _taskStatusCount = counts;
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedDate =
          DateTime(_selectedDate.year, _selectedDate.month + offset, 1);
      _loadData();
    });
  }

  Widget _buildPieChart() {
    final total = _taskStatusCount.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) {
      return const Center(child: Text('Tidak ada data tugas untuk bulan ini'));
    }

    final colors = {
      'Selesai': Colors.green,
      'Pending': Colors.orange,
      'Terlambat': Colors.red,
    };

    List<PieChartSectionData> sections = _taskStatusCount.entries.map((entry) {
      final percent = (entry.value / total) * 100;
      final color = colors[entry.key] ?? Colors.grey;

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.key}\n${percent.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 4,
        centerSpaceRadius: 30,
      ),
    );
  }

  Widget _buildTaskListByStatus(String status) {
    final filteredTasks =
        _tasks.where((tugas) => tugas['status'] == status).toList();

    if (filteredTasks.isEmpty) {
      return const Center(child: Text('Tidak ada tugas untuk status ini'));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredTasks.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final tugas = filteredTasks[index];
        final tanggal = tugas['tanggal'] as DateTime;
        final namaTugas = tugas['namaTugas'] ?? 'Tidak ada nama tugas';

        Color statusColor;
        switch (status) {
          case 'Selesai':
            statusColor = Colors.green;
            break;
          case 'Pending':
            statusColor = Colors.orange;
            break;
          case 'Terlambat':
            statusColor = Colors.red;
            break;
          default:
            statusColor = Colors.grey;
        }

        return ListTile(
          title: Text(namaTugas),
          subtitle:
              Text('Tanggal: ${tanggal.day}-${tanggal.month}-${tanggal.year}'),
          trailing: Text(
            status,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthYear =
        '${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.year}';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                Navigator.pop(context);
              },
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
            title: const Text(
              'Rekap Tugas',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
        body: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Navigasi bulan
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => _changeMonth(-1),
                      color: const Color.fromARGB(255, 127, 157, 195),
                    ),
                    Text(
                      monthYear,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 127, 157, 195)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () => _changeMonth(1),
                      color: const Color.fromARGB(255, 127, 157, 195),
                    ),
                  ],
                ),

                // Pie chart
                SizedBox(height: 200, child: _buildPieChart()),
                const SizedBox(height: 20),

                // TabBar
                const TabBar(
                  labelColor: Color.fromARGB(
                      255, 127, 157, 195), // Warna saat tab dipilih
                  unselectedLabelColor:
                      Colors.grey, // Warna saat tab belum dipilih
                  indicatorColor: Color.fromARGB(
                      255, 127, 157, 195), // Garis bawah tab aktif
                  tabs: [
                    Tab(text: 'Selesai'),
                    Tab(text: 'Pending'),
                    Tab(text: 'Terlambat'),
                  ],
                ),

                const SizedBox(height: 10),

                // TabBarView
                SizedBox(
                  height: 300, // adjust as needed
                  child: TabBarView(
                    children: [
                      _buildTaskListByStatus('Selesai'),
                      _buildTaskListByStatus('Pending'),
                      _buildTaskListByStatus('Terlambat'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
