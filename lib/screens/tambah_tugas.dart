import 'package:flutter/material.dart';
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
        title: const Text('Tambah Tugas Baru'),
        content: TextField(
          controller: _newTaskController,
          decoration: const InputDecoration(
            hintText: 'Masukkan nama tugas baru',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _newTaskController.clear();
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              if (_newTaskController.text.isNotEmpty) {
                try {
                  await FirebaseFirestore.instance.collection('tasks').add({
                    'name': _newTaskController.text,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  await fetchTasks(); // Refresh the task list
                  Navigator.pop(context);
                  _newTaskController.clear();
                } catch (e) {
                  // ignore: avoid_print
                  print('Error adding task: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal menambahkan tugas')),
                  );
                }
              }
            },
            child: const Text('Tambah'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: allTasks.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(allTasks[index]),
                onTap: () {
                  _removeTask(allTasks[index]);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
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
                    const Center(
                      child: Text(
                        "Tugas Baru",
                        style: TextStyle(
                          color: Color(0xFF001F3D),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Pilih Tugas :",
                          style: TextStyle(color: Color(0xFF001F3D)),
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
                                label: Text(task),
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
                                selectedColor: Colors.blue,
                                checkmarkColor: Colors.white,
                                backgroundColor: Colors.blue[50],
                                labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.blue),
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Pilih Karyawan :",
                        style: TextStyle(
                          color: Color(0xFF001F3D),
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
                                label: Text(nama),
                                selected: selectedKaryawan == nama,
                                onSelected: (bool selected) {
                                  setState(() {
                                    selectedKaryawan = selected ? nama : null;
                                  });
                                },
                                selectedColor: Colors.blue,
                                backgroundColor: Colors.blue[50],
                                labelStyle: TextStyle(
                                  color: selectedKaryawan == nama
                                      ? Colors.white
                                      : Colors.blue,
                                ),
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
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                          style: const TextStyle(
                            fontSize: 16,
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
                                prefixIcon: const Icon(Icons.access_time),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                startTime.format(context),
                                style: const TextStyle(
                                  fontSize: 16,
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
                                prefixIcon: const Icon(Icons.access_time),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                endTime.format(context),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
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
                              colors: [Color(0xFF001F3D), Color(0xFF001F3D)],
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
                                : const Text(
                                    "Buat Tugas",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                          ),
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
      lastDate: DateTime(2101),
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
    );
    if (picked != null && picked != endTime) {
      setState(() {
        endTime = picked;
      });
    }
  }
}
