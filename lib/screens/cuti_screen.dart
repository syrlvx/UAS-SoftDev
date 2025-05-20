import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CutiScreen extends StatefulWidget {
  const CutiScreen({super.key});

  @override
  _CutiScreenState createState() => _CutiScreenState();
}

class _CutiScreenState extends State<CutiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _linkFileController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .get();

        if (userData.exists) {
          setState(() {
            _username = userData.data()?['username'] ?? 'Unknown';
            _namaController.text = _username ?? '';
          });
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat data pengguna'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _linkFileController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF001F3D),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('User not logged in');
        }

        // Create data map
        final data = {
          'nama': _username,
          'tanggal': Timestamp.fromDate(_selectedDate),
          'linkFile': _linkFileController.text,
          'status': 'Pending',
          'userId': user.uid,
          'createdAt': Timestamp.now(),
          'jenis': 'cuti',
        };

        // Submit to Firestore
        await FirebaseFirestore.instance.collection('pengajuan').add(data);

        // Reset form
        _linkFileController.clear();
        setState(() {
          _selectedDate = DateTime.now();
          _isLoading = false;
        });

        // Show success message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Pengajuan cuti berhasil dikirim'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        // Show error message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 10),
                Text('Gagal mengirim pengajuan'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF001F3D), // Biru navy gelap
                Color(0xFFFFFFFF), // Putih
              ],
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        leadingWidth: 80,
        title: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Colors.white70],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: const Text(
                    "Form Cuti",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
        centerTitle: true,
        actions: const [
          SizedBox(width: 65),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(35),
          child: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, -2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Data Pengajuan",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF001F3D),
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextFormField(
                    controller: _namaController,
                    enabled: false,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      // Ukuran font input
                    ),
                    decoration: InputDecoration(
                      labelText: 'Nama',
                      labelStyle: const TextStyle(
                        color: Color(0xFF001F3D),
                        fontSize: 21, // Ukuran font label
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Color(0xFF001F3D),
                        size: 24, // Ukuran ikon kalau mau dikecilkan juga
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Color(0xFF001F3D)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Color(0xFF001F3D)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                            color: Color(0xFF001F3D), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 18, // Ukuran font hint
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () => _selectDate(context),
                    splashColor: const Color(0xFF001F3D).withOpacity(0.2),
                    highlightColor: const Color(0xFF001F3D).withOpacity(0.1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: const Color(0xFF001F3D)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Color(0xFF001F3D)),
                          const SizedBox(width: 10),
                          Text(
                            "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF001F3D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _linkFileController,
                    style: TextStyle(
                      // <- font dalam text field
                      color: Colors.black87,
                      fontSize: 16, // ubah ukuran font isian di sini
                    ),
                    decoration: InputDecoration(
                      labelText: 'Link File Bukti Cuti',
                      labelStyle: TextStyle(
                        color: Color(0xFF001F3D),
                        fontSize: 16, // font label
                      ),
                      prefixIcon:
                          Icon(Icons.link, color: Color(0xFF001F3D), size: 22),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Color(0xFF001F3D)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Color(0xFF001F3D)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Color(0xFF001F3D), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      hintStyle: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 16,
                      ),
                      helperText: 'Masukkan link Google Drive',
                      helperStyle:
                          TextStyle(fontSize: 12), // <- font helperText
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Link file bukti cuti harus diisi';
                      }
                      if (!value.startsWith('http://') &&
                          !value.startsWith('https://')) {
                        return 'Link harus dimulai dengan http:// atau https://';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 2,
                        padding: EdgeInsets.zero,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF001F3D), // Biru navy gelap
                              Color(0xFFFFFFFF), // Putih
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text(
                                    'kirim pengajuan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
