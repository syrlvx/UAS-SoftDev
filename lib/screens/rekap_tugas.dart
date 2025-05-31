import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class RekapTugasScreen extends StatefulWidget {
  const RekapTugasScreen({super.key});

  @override
  State<RekapTugasScreen> createState() => _RekapTugasScreenState();
}

class _RekapTugasScreenState extends State<RekapTugasScreen> {
  late DateTime _selectedDate;
  List<Map<String, dynamic>> _tasks = [];
  Map<String, int> _taskStatusCount = {};
  bool isLoading = true;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Set start and end of the selected month
      final startOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final endOfMonth =
          DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);

      final querySnapshot = await FirebaseFirestore.instance
          .collection('tugas')
          .where('karyawanUid', isEqualTo: user.uid)
          .where('tanggal',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      List<Map<String, dynamic>> tasks = [];
      Map<String, int> counts = {
        'Selesai': 0,
        'Pending': 0,
        'Terlambat': 0,
      };

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final status = data['status'] ?? 'Pending';
        final isLate = data['isLate'] ?? false;

        String taskStatus = status;
        if (status == 'Selesai' && isLate) {
          taskStatus = 'Terlambat';
        } else if (status != 'Selesai') {
          final waktuSelesai = (data['waktuSelesai'] as Timestamp).toDate();
          if (waktuSelesai.isBefore(DateTime.now())) {
            taskStatus = 'Terlambat';
          }
        }

        counts[taskStatus] = (counts[taskStatus] ?? 0) + 1;

        tasks.add({
          'namaTugas': (data['jenisTugas'] as List).join(', '),
          'tanggal': (data['tanggal'] as Timestamp).toDate(),
          'status': taskStatus,
          'waktuSelesai': (data['waktuSelesai'] as Timestamp).toDate(),
        });
      }

      setState(() {
        _tasks = tasks;
        _taskStatusCount = counts;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading tasks: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedDate =
          DateTime(_selectedDate.year, _selectedDate.month + offset, 1);
      _loadData();
    });
  }

  void _showCalendar() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Month and Year Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(
                            _selectedDate.year, _selectedDate.month - 1, 1);
                      });
                      Navigator.pop(context);
                      _loadData();
                    },
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(_selectedDate),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 127, 157, 195),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(
                            _selectedDate.year, _selectedDate.month + 1, 1);
                      });
                      Navigator.pop(context);
                      _loadData();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Month Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final isSelected = month == _selectedDate.month;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDate = DateTime(_selectedDate.year, month, 1);
                      });
                      Navigator.pop(context);
                      _loadData();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color.fromARGB(255, 127, 157, 195)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color.fromARGB(255, 127, 157, 195)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          DateFormat('MMM').format(DateTime(2024, month, 1)),
                          style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

// Year selection
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(
                            _selectedDate.year - 1, _selectedDate.month, 1);
                      });
                      Navigator.pop(context);
                      _loadData();
                    },
                  ),
                  Text(
                    _selectedDate.year.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 127, 157, 195),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(
                            _selectedDate.year + 1, _selectedDate.month, 1);
                      });
                      Navigator.pop(context);
                      _loadData();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final total = _taskStatusCount.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) {
      return const Center(child: Text('Tidak ada data tugas untuk hari ini'));
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
        title: '${percent.toStringAsFixed(1)}%',
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
      return Center(
        child: Text(
          'Tidak ada tugas untuk status ini',
          style: GoogleFonts.poppins(fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      itemCount: filteredTasks.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final tugas = filteredTasks[index];
        final tanggal = tugas['tanggal'] as DateTime;
        final namaTugas = tugas['namaTugas'] ?? 'Tidak ada nama tugas';
        final waktuSelesai = tugas['waktuSelesai'] as DateTime;

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
          title: Text(
            namaTugas,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tanggal: ${DateFormat('dd MMMM yyyy').format(tanggal)}',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              Text(
                'Deadline: ${DateFormat('HH:mm').format(waktuSelesai)}',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ],
          ),
          trailing: Text(
            status,
            style: GoogleFonts.poppins(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMMM yyyy').format(_selectedDate);
    final isCurrentMonth = _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month;

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
            title: Text(
              'Rekap Tugas',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                color: Colors.white,
                child: Column(
                  children: [
                    // Month navigation
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => _changeMonth(-1),
                            color: const Color.fromARGB(255, 127, 157, 195),
                          ),
                          InkWell(
                            onTap: _showCalendar,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isCurrentMonth
                                        ? 'Bulan Ini'
                                        : formattedDate,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(
                                          255, 127, 157, 195),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Color.fromARGB(255, 127, 157, 195),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () => _changeMonth(1),
                            color: const Color.fromARGB(255, 127, 157, 195),
                          ),
                        ],
                      ),
                    ),

                    // Pie chart
                    SizedBox(height: 200, child: _buildPieChart()),
                    const SizedBox(height: 20),

                    // TabBar
                    TabBar(
                      labelColor: const Color.fromARGB(255, 127, 157, 195),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color.fromARGB(255, 127, 157, 195),
                      labelStyle:
                          GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      unselectedLabelStyle: GoogleFonts.poppins(),
                      tabs: const [
                        Tab(text: 'Selesai'),
                        Tab(text: 'Pending'),
                        Tab(text: 'Terlambat'),
                      ],
                    ),

                    // TabBarView
                    Expanded(
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
    );
  }
}
