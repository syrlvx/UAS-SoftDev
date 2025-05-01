import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IzinScreen extends StatefulWidget {
  @override
  _IzinScreenState createState() => _IzinScreenState();
}

class _IzinScreenState extends State<IzinScreen> {
  final _formKey = GlobalKey<FormState>();
  String _nama = '';
  String _keterangan = '';
  DateTime _selectedDate = DateTime.now();

  // Fungsi untuk memilih tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  // Fungsi untuk menyimpan data ke Firestore
  Future<void> _saveDataToFirestore() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Menyimpan data ke koleksi 'izin' di Firestore
        await FirebaseFirestore.instance.collection('izin').add({
          'nama': _nama,
          'tanggal': _selectedDate,
          'keterangan': _keterangan,
        });

        // Tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Form Izin berhasil dikirim')),
        );
      } catch (e) {
        // Menangani error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim form: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Set background warna biru
        iconTheme: IconThemeData(color: Colors.white), // Tombol back putih
        titleTextStyle:
            TextStyle(color: Colors.white, fontSize: 20), // Teks judul putih
        title: Text("Form Izin"), // Judul tetap ada
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white, // Background putih untuk bagian bawah
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Field untuk Nama
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nama',
                  labelStyle:
                      TextStyle(color: Colors.black), // Warna label hitam
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama harus diisi';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _nama = value;
                  });
                },
              ),
              SizedBox(height: 20),

              // Field untuk memilih Tanggal
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Tanggal',
                      labelStyle:
                          TextStyle(color: Colors.black), // Warna label hitam
                      border: OutlineInputBorder(),
                      hintText: '${_selectedDate.toLocal()}'.split(' ')[0],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tanggal harus dipilih';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Field untuk Keterangan
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Keterangan',
                  labelStyle:
                      TextStyle(color: Colors.black), // Warna label hitam
                  border: OutlineInputBorder(),
                ),
                maxLines: 4, // Bisa lebih dari satu baris
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Keterangan harus diisi';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _keterangan = value;
                  });
                },
              ),
              SizedBox(height: 20),

              // Tombol Kirim untuk mengirim data
              ElevatedButton(
                onPressed: _saveDataToFirestore,
                child: Text('Kirim',
                    style: TextStyle(color: Colors.white)), // Teks putih
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Background tombol biru
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
