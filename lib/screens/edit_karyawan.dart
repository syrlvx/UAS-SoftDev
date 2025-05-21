import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditKaryawanScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const EditKaryawanScreen({super.key, required this.data});

  @override
  State<EditKaryawanScreen> createState() => _EditKaryawanScreenState();
}

class _EditKaryawanScreenState extends State<EditKaryawanScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController performanceScoreController;
  late TextEditingController notesController;

  String? selectedPosition;

  final List<String> posisiOptions = ['Karyawan', 'Admin'];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.data['name'] ?? '');
    emailController = TextEditingController(text: widget.data['email'] ?? '');
    performanceScoreController =
        TextEditingController(text: '${widget.data['skorKinerja'] ?? 0}');
    notesController = TextEditingController(text: widget.data['catatan'] ?? '');

    // Set posisi dropdown value awal
    selectedPosition = widget.data['posisi'] ?? posisiOptions[0];
  }

  Future<void> updateKaryawan() async {
    try {
      await FirebaseFirestore.instance
          .collection('karyawan')
          .doc(widget.data['id'])
          .update({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'posisi': selectedPosition,
        'skorKinerja': int.tryParse(performanceScoreController.text) ?? 0,
        'catatan': notesController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil diperbarui')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF001F3D);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: navyColor,
        title: Text(
          'Edit Karyawan',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(label: 'Nama', controller: nameController),
            _buildTextField(
                label: 'Email',
                controller: emailController,
                keyboardType: TextInputType.emailAddress),
            _buildDropdownPosition(),
            _buildTextField(
                label: 'Skor Kinerja',
                controller: performanceScoreController,
                keyboardType: TextInputType.number),
            _buildTextField(
                label: 'Catatan', controller: notesController, maxLines: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: updateKaryawan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: navyColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Simpan Perubahan',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul/Label dengan font size 22
          Text(
            label,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          // TextField dengan font size 16
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(
                fontSize: 16, color: Colors.black), // Ukuran teks input
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownPosition() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Posisi',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            child: DropdownButtonFormField<String>(
              isExpanded: true, // Pastikan item teks gak kepotong
              value: selectedPosition,
              onChanged: (value) {
                setState(() {
                  selectedPosition = value;
                });
              },
              items: posisiOptions.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              menuMaxHeight:
                  200, // Batas tinggi dropdown agar tidak terlalu panjang
            ),
          ),
        ],
      ),
    );
  }
}
