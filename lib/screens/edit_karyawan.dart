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
  late TextEditingController notesController;
  bool isLoading = true;

  String? selectedPosition;

  final List<String> posisiOptions = ['karyawan', 'admin'];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.data['username'] ?? '');
    emailController = TextEditingController(text: widget.data['email'] ?? '');
    notesController = TextEditingController(text: widget.data['notes'] ?? '');

    // Set initial position value, defaulting to 'karyawan' if not found
    selectedPosition = widget.data['role']?.toLowerCase() ?? 'karyawan';
    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateKaryawan() async {
    try {
      print('Updating user data for ID: ${widget.data['id']}');

      // Update user data in Firestore
      await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.data['id'])
          .update({
        'username': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': selectedPosition,
        'notes': notesController.text.trim(),
      });

      print('User data updated successfully');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );

      // Pop back to previous screen
      Navigator.pop(context);
    } catch (e) {
      print('Error updating user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal update data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF001F3D);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
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
            padding: const EdgeInsets.only(top: 10),
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
          backgroundColor: Colors.transparent,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                      label: 'Catatan',
                      controller: notesController,
                      maxLines: 3),
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
