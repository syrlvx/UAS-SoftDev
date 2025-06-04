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

  final List<String> posisiOptions = ['karyawan', 'admin'];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.data['username'] ?? '');
    emailController = TextEditingController(text: widget.data['email'] ?? '');
    performanceScoreController =
        TextEditingController(text: '${widget.data['score'] ?? 0}');
    notesController = TextEditingController(text: widget.data['notes'] ?? '');

    // Set initial position value, defaulting to 'karyawan' if not found
    selectedPosition = widget.data['role']?.toLowerCase() ?? 'karyawan';
  }

  Future<void> updateKaryawan() async {
    try {
      // Validate score
      int score = int.tryParse(performanceScoreController.text) ?? 0;
      if (score < 0 || score > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Skor kinerja harus antara 0-100')),
        );
        return;
      }

      // Update data in Firestore
      await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.data['id'])
          .update({
        'username': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': selectedPosition,
        'score': score,
        'notes': notesController.text.trim(),
      });

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil diperbarui')),
      );

      // Return true to indicate successful update and trigger refresh
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70), // Tinggi 70
        child: AppBar(
          automaticallyImplyLeading: true,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF001F3D), Color.fromARGB(255, 255, 255, 255)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 10), // supaya teks agak turun
            child: Text(
              'Edit Karyawan',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          backgroundColor: Colors.transparent, // Biar gradasinya terlihat
        ),
      ),
      body: SingleChildScrollView(
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
                label: 'Skor Kinerja (0-100)',
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
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
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
          Text(
            'Posisi',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
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
                    item.toUpperCase(), // Display in uppercase for better appearance
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              dropdownColor: Colors.white,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
