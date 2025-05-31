import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purelux/widgets/bottom_nav_bar_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart'; // Tambahkan package ini untuk generate uid

class TambahTugasScreen extends StatefulWidget {
  const TambahTugasScreen({Key? key}) : super(key: key);

  @override
  State<TambahTugasScreen> createState() => _TambahTugasScreenState();
}

class _TambahTugasScreenState extends State<TambahTugasScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 11, minute: 0);
  bool isLoading = false; // Untuk menampilkan loading indicator
  bool isLoadingTasks = true;

  List<String> allTasks = [];
  final List<String> selectedTasks = [];
  final TextEditingController _newTaskController = TextEditingController();

  final List<String> allEmployees = [
    'Fara',
    'Ratna',
    'Ines',
    'Dion',
  ];
  final List<String> selectedEmployees = [];
  String selectedCategory = 'Development';
  String? selectedKaryawan;

  List<String> karyawanList = [];
  List<Map<String, dynamic>> karyawanDataList =
      []; // Untuk menyimpan data lengkap karyawan
  bool isLoadingKaryawan = true;

  @override
  void initState() {
    super.initState();
    fetchKaryawan();
    fetchTasks();
  }

  Future<void> fetchKaryawan() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('role', isEqualTo: 'karyawan')
          .get();

      final List<String> namaList = [];
      final List<Map<String, dynamic>> dataList = [];

      for (var doc in snapshot.docs) {
        String nama = doc['username']?.toString() ?? '';
        if (nama.isNotEmpty) {
          namaList.add(nama);
          dataList.add({
            'uid': doc.id,
            'username': nama,
          });
        }
      }

      setState(() {
        karyawanList = namaList;
        karyawanDataList = dataList;
        isLoadingKaryawan = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching karyawan: $e');
      setState(() {
        isLoadingKaryawan = false;
      });
    }
  }

  Future<void> fetchTasks() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .orderBy('name')
          .get();

      setState(() {
        allTasks = snapshot.docs.map((doc) => doc['name'] as String).toList();
        isLoadingTasks = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching tasks: $e');
      setState(() {
        isLoadingTasks = false;
      });
    }
  }

  // Fungsi untuk mendapatkan uid karyawan berdasarkan username yang dipilih
  String? getSelectedKaryawanUid() {
    if (selectedKaryawan == null) return null;

    for (var karyawan in karyawanDataList) {
      if (karyawan['username'] == selectedKaryawan) {
        return karyawan['uid'];
      }
    }
    return null;
  }

  // Fungsi untuk menambahkan tugas ke Firestore
  Future<void> saveTugasToFirestore() async {
    if (selectedTasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu tugas')),
      );
      return;
    }

    if (selectedKaryawan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih karyawan')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final String? karyawanUid = getSelectedKaryawanUid();
      if (karyawanUid == null) {
        throw Exception('Karyawan UID tidak ditemukan');
      }

      final String tugasId =
          const Uuid().v4(); // Generate unique ID untuk dokumen tugas

      // Konversi TimeOfDay ke timestamp (jam dan menit saja)
      final DateTime startDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        startTime.hour,
        startTime.minute,
      );

      final DateTime endDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        endTime.hour,
        endTime.minute,
      );

      // Data yang akan disimpan ke Firestore
      final Map<String, dynamic> tugasData = {
        'tugasId': tugasId,
        'karyawanUid': karyawanUid,
        'karyawanNama': selectedKaryawan,
        'jenisTugas': selectedTasks,
        'tanggal': Timestamp.fromDate(selectedDate),
        'waktuMulai': Timestamp.fromDate(startDateTime),
        'waktuSelesai': Timestamp.fromDate(endDateTime),
        'status': 'belum_dikerjakan', // Default status
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Simpan data ke Firestore
      await FirebaseFirestore.instance
          .collection('tugas')
          .doc(tugasId)
          .set(tugasData);

      setState(() {
        isLoading = false;
      });

      // Tampilkan notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas berhasil dibuat')),
      );

      // Reset form untuk entry baru
      setState(() {
        selectedTasks.clear();
        selectedKaryawan = null;
        selectedDate = DateTime.now();
        startTime = const TimeOfDay(hour: 10, minute: 0);
        endTime = const TimeOfDay(hour: 11, minute: 0);
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      // Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      // ignore: avoid_print
      print('Error saving tugas: $e');
    }
  }

  Future<void> _addNewTask() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // warna latar putih
        title: Text(
          'Tambah Tugas',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: _newTaskController,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Masukkan tugas baru',
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _newTaskController.clear();
            },
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (_newTaskController.text.isNotEmpty) {
                try {
                  await FirebaseFirestore.instance.collection('tasks').add({
                    'name': _newTaskController.text,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  await fetchTasks();
                  Navigator.pop(context);
                  _newTaskController.clear();
                } catch (e) {
                  print('Error adding task: $e');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      'Gagal menambahkan tugas',
                      style: GoogleFonts.poppins(),
                    ),
                  ));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF001F3D), // warna navy
            ),
            child: Text(
              'Tambah',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _removeTask(String task) async {
    try {
      // Find the task document
      final querySnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('name', isEqualTo: task)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Delete the task document
        await querySnapshot.docs.first.reference.delete();

        setState(() {
          allTasks.remove(task);
          selectedTasks.remove(task);
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error removing task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus tugas')),
      );
    }
  }

  void _showRemoveTaskDialog() {
    String? selectedTask;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              'Hapus Tugas',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: allTasks.length,
                itemBuilder: (context, index) {
                  final task = allTasks[index];
                  return RadioListTile<String>(
                    title: Text(
                      task,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    value: task,
                    groupValue: selectedTask,
                    activeColor: Colors.red,
                    onChanged: (value) {
                      setState(() {
                        selectedTask = value;
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: selectedTask != null
                    ? () {
                        _removeTask(selectedTask!);
                        Navigator.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedTask != null ? Colors.red : Colors.grey.shade300,
                  foregroundColor:
                      selectedTask != null ? Colors.white : Colors.grey,
                ),
                child: Text(
                  'Hapus',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradasi
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF001F3D), Color(0xFFFFFFFF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Tombol kembali
          Positioned(
            top: 35,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BottomNavBarAdmin()),
                );
              },
            ),
          ),

          // Kontainer isi
          Positioned(
            top: 90,
            left: 20,
            right: 20,
            bottom: 20,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Tugas Baru",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF001F3D),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pilih Tugas :",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF001F3D),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add_circle,
                                  color: Color(0xFF001F3D)),
                              onPressed: _addNewTask,
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Color(0xFF001F3D)),
                              onPressed: _showRemoveTaskDialog,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    isLoadingTasks
                        ? const Center(child: CircularProgressIndicator())
                        : Wrap(
                            spacing: 10,
                            children: allTasks.map((task) {
                              final isSelected = selectedTasks.contains(task);
                              return FilterChip(
                                label: Text(
                                  task,
                                  style: GoogleFonts.poppins(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF001F3D),
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedTasks.add(task);
                                    } else {
                                      selectedTasks.remove(task);
                                    }
                                  });
                                },
                                selectedColor: const Color(0xFF001F3D),
                                checkmarkColor: Colors.white,
                                backgroundColor: Colors.white,
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Pilih Karyawan :",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF001F3D),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    isLoadingKaryawan
                        ? const Center(child: CircularProgressIndicator())
                        : Wrap(
                            spacing: 10,
                            children: karyawanList.map((nama) {
                              return ChoiceChip(
                                label: Text(
                                  nama,
                                  style: GoogleFonts.poppins(
                                    color: selectedKaryawan == nama
                                        ? Colors.white
                                        : const Color(0xFF001F3D),
                                  ),
                                ),
                                selected: selectedKaryawan == nama,
                                onSelected: (bool selected) {
                                  setState(() {
                                    selectedKaryawan = selected ? nama : null;
                                  });
                                },
                                selectedColor: const Color(0xFF001F3D),
                                checkmarkColor: Colors.white,
                                backgroundColor: Colors.white,
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 5),
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "Tanggal",
                          labelStyle: GoogleFonts.poppins(
                              color: Colors.grey[700], fontSize: 18),
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _selectStartTime,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: "Mulai",
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.grey[700],
                                ),
                                prefixIcon: const Icon(Icons.access_time),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                startTime.format(context),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: _selectEndTime,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: "Selesai",
                                labelStyle: GoogleFonts.poppins(
                                    color: Colors.grey[700], fontSize: 18),
                                prefixIcon: const Icon(Icons.access_time),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                endTime.format(context),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : saveTugasToFirestore,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF001F3D),
                                Color(0xFFFFFFFF),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              alignment: Alignment.center,
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text("Buat Tugas",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 18,
                                      ))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF001F3D), // header & tombol OK
              onPrimary: Colors.white, // teks header
              onSurface: Colors.black, // warna tanggal aktif
              background: Colors.white, // background modal
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF001F3D), // tombol CANCEL dan OK
              ),
            ),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.black), // teks tanggal biasa
              bodyLarge: TextStyle(color: Colors.black), // teks tanggal besar
              bodySmall: TextStyle(color: Colors.black), // teks tanggal kecil
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(alwaysUse24HourFormat: false), // PAKSA format 12 jam
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Color(0xFF001F3D),
                onPrimary: Colors.white,
                onSurface: Colors.black,
                background: Colors.white,
              ),
              dialogBackgroundColor: Colors.white,
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xFF001F3D),
                ),
              ),
              timePickerTheme: TimePickerThemeData(
                hourMinuteColor: MaterialStateColor.resolveWith((states) =>
                    states.contains(MaterialState.selected)
                        ? Color(0xFF001F3D)
                        : Colors.transparent),
                hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
                    states.contains(MaterialState.selected)
                        ? Colors.white
                        : Colors.black),
                dayPeriodColor: MaterialStateColor.resolveWith((states) =>
                    states.contains(MaterialState.selected)
                        ? Color(0xFF001F3D)
                        : Colors.white),
                dayPeriodTextColor: MaterialStateColor.resolveWith((states) =>
                    states.contains(MaterialState.selected)
                        ? Colors.white
                        : Colors.black),
                dayPeriodShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Color(0xFF001F3D)),
                ),
                dialHandColor: Color(0xFF001F3D),
                dialBackgroundColor: Colors.white,
                entryModeIconColor: Color(0xFF001F3D),
              ),
            ),
            child: child!,
          ),
        );
      },
    );
    if (picked != null && picked != startTime) {
      setState(() {
        startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: endTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(alwaysUse24HourFormat: false), // PAKSA format 12 jam
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Color(0xFF001F3D),
                onPrimary: Colors.white,
                onSurface: Colors.black,
                background: Colors.white,
              ),
              dialogBackgroundColor: Colors.white,
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xFF001F3D),
                ),
              ),
              timePickerTheme: TimePickerThemeData(
                hourMinuteColor: MaterialStateColor.resolveWith((states) =>
                    states.contains(MaterialState.selected)
                        ? Color(0xFF001F3D)
                        : Colors.transparent),
                hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
                    states.contains(MaterialState.selected)
                        ? Colors.white
                        : Colors.black),
                dayPeriodColor: MaterialStateColor.resolveWith((states) =>
                    states.contains(MaterialState.selected)
                        ? Color(0xFF001F3D)
                        : Colors.white),
                dayPeriodTextColor: MaterialStateColor.resolveWith((states) =>
                    states.contains(MaterialState.selected)
                        ? Colors.white
                        : Colors.black),
                dayPeriodShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Color(0xFF001F3D)),
                ),
                dialHandColor: Color(0xFF001F3D),
                dialBackgroundColor: Colors.white,
                entryModeIconColor: Color(0xFF001F3D),
              ),
            ),
            child: child!,
          ),
        );
      },
    );
    if (picked != null && picked != endTime) {
      setState(() {
        endTime = picked;
      });
    }
  }
}
