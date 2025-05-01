import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TugasAdminScreen extends StatefulWidget {
  @override
  _TugasAdminScreenState createState() => _TugasAdminScreenState();
}

class _TugasAdminScreenState extends State<TugasAdminScreen> {
  String? _selectedKaryawan;
  String? _selectedJobdesk;
  List<String> karyawanList = [];
  List<String> jobdesks = [
    'Cuci & Keringkan Pakaian',
    'Setrika Pakaian',
    'Sortir Pakaian',
    'Pakai Mesin Pengering',
    'Pilih Paket Laundry'
  ];
  TextEditingController _deadlineController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchKaryawan();
  }

  Future<void> _fetchKaryawan() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('user').get();

      setState(() {
        karyawanList = snapshot.docs
            .map((doc) => doc['username']?.toString() ?? '')
            .where((username) => username.isNotEmpty)
            .toList();
      });
    } catch (e) {
      print("Error fetching karyawan data: $e");
    }
  }

  Future<void> _tambahTugas() async {
    if (_selectedKaryawan == null ||
        _selectedJobdesk == null ||
        _deadlineController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap lengkapi semua field.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('tugas').add({
        'karyawan': _selectedKaryawan,
        'jobdesk': _selectedJobdesk,
        'deadline': _deadlineController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tugas berhasil ditambahkan!')),
      );

      // Reset form
      setState(() {
        _selectedKaryawan = null;
        _selectedJobdesk = null;
        _deadlineController.clear();
      });
    } catch (e) {
      print("Error adding task: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        final selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        _deadlineController.text =
            '${selectedDateTime.year}-${selectedDateTime.month.toString().padLeft(2, '0')}-${selectedDateTime.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Tambah Tugas untuk Karyawan'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedKaryawan,
              decoration: InputDecoration(
                labelText: 'Pilih Karyawan (Username)',
                border: OutlineInputBorder(),
              ),
              items: karyawanList.map((karyawan) {
                return DropdownMenuItem<String>(
                  value: karyawan,
                  child: Text(karyawan),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedKaryawan = value;
                });
              },
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedJobdesk,
              decoration: InputDecoration(
                labelText: 'Pilih Jobdesk',
                border: OutlineInputBorder(),
              ),
              items: jobdesks.map((jobdesk) {
                return DropdownMenuItem<String>(
                  value: jobdesk,
                  child: Text(jobdesk),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedJobdesk = value;
                });
              },
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _selectDateTime,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _deadlineController,
                  decoration: InputDecoration(
                    labelText: 'Deadline (Tanggal & Jam)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _tambahTugas,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text('Tambah Tugas'),
                  ),
          ],
        ),
      ),
    );
  }
}
