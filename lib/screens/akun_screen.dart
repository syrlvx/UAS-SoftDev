import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purelux/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:image_picker/image_picker.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final auth = FirebaseAuth.instance;
  String? username;
  String? email;
  String? phoneNumber;
  String? photoUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        final uid = user.uid;
        final doc =
            await FirebaseFirestore.instance.collection('user').doc(uid).get();
        if (doc.exists) {
          setState(() {
            username = doc['username'];
            email = user.email;
            phoneNumber = doc.data()?['phone'] ?? '';
            photoUrl = doc.data()?['foto'];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      _showError(context, "Gagal mengambil data: $e");
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      final uid = auth.currentUser!.uid;
      final fileBytes = await picked.readAsBytes();
      final fileExt = picked.path.split('.').last;
      final fileName = '$uid.$fileExt';
      // Upload ke Supabase Storage bucket 'foto' dengan nama file = uid.ext
      final sb = supabase.Supabase.instance.client;
      await sb.storage.from('foto').uploadBinary(
            fileName,
            fileBytes,
            fileOptions: const supabase.FileOptions(upsert: true),
          );
      final publicUrl = sb.storage.from('foto').getPublicUrl(fileName);
      // Simpan link ke Firestore
      await FirebaseFirestore.instance.collection('user').doc(uid).update({
        'foto': publicUrl,
      });
      setState(() {
        photoUrl = publicUrl;
      });
    } catch (e) {
      _showError(context, "Gagal upload foto: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          title: const Text("Akun Saya", style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF001F3D),
                  Color(0xFFFFFFFF),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickAndUploadPhoto,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue.shade700,
                      backgroundImage:
                          (photoUrl != null && photoUrl!.isNotEmpty)
                              ? NetworkImage(photoUrl!)
                              : null,
                      child: (photoUrl == null || photoUrl!.isEmpty)
                          ? Text(
                              (username?.isNotEmpty == true)
                                  ? username![0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    username ?? 'User',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    email ?? 'user@example.com',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (phoneNumber != null && phoneNumber!.isNotEmpty)
                    Text(
                      phoneNumber!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 25),
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shadowColor: Colors.grey,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 5,
                                spreadRadius: 1,
                                offset: const Offset(0, -20)),
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 5,
                                spreadRadius: 1,
                                offset: const Offset(2, 0)),
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 5,
                                spreadRadius: 1,
                                offset: const Offset(-2, 0)),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.person_outline),
                                title: Text(
                                  "Ubah Username",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: const Color(0xFF001F3D),
                                  ), // Ukuran font lebih kecil
                                ),
                                trailing: const Icon(Icons.edit),
                                onTap: () => _editUsernameDialog(context),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.lock_outline),
                                title: Text(
                                  "Ubah Password",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: const Color(0xFF001F3D),
                                  ),
                                ),
                                trailing: const Icon(Icons.edit),
                                onTap: () => _editPasswordDialog(context),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.phone_android),
                                title: Text(
                                  "Ubah No Telepon",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: const Color(0xFF001F3D),
                                  ),
                                ),
                                trailing: const Icon(Icons.edit),
                                onTap: () => _editPhoneDialog(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: Text(
                      "Logout",
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor:
                          Colors.white, // untuk teks dan icon default
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 120),
                  Text(
                    "Versi 1.0.0",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                  Text(
                    "© 2025 PureLux",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }

  void _editUsernameDialog(BuildContext context) {
    final controller = TextEditingController(text: username ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          "Ubah Username",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon:
                const Icon(Icons.person_outline, color: Color(0xFF001F3D)),
            hintText: "Masukkan username baru",
            hintStyle: GoogleFonts.poppins(color: const Color(0xFF001F3D)),
            border: const OutlineInputBorder(),
          ),
          style:
              GoogleFonts.poppins(color: const Color(0xFF001F3D), fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Batal",
              style: GoogleFonts.poppins(
                color: const Color(0xFF001F3D),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUsername = controller.text.trim();
              if (newUsername.isNotEmpty) {
                final uid = auth.currentUser!.uid;
                await FirebaseFirestore.instance
                    .collection('user')
                    .doc(uid)
                    .update({'username': newUsername});
                setState(() => username = newUsername);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF001F3D),
            ),
            child: Text(
              "Simpan",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editPasswordDialog(BuildContext context) {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          "Ubah Password",
          style: GoogleFonts.poppins(
            color: const Color(0xFF001F3D), // Navy
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.black),
                labelText: "Password Lama",
                labelStyle: GoogleFonts.poppins(color: Colors.black54),
                border: const OutlineInputBorder(),
              ),
              style: GoogleFonts.poppins(color: Colors.black),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_open, color: Colors.black),
                labelText: "Password Baru",
                labelStyle: GoogleFonts.poppins(color: Colors.black54),
                border: const OutlineInputBorder(),
              ),
              style: GoogleFonts.poppins(color: Colors.black),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Batal",
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final user = auth.currentUser!;
                final cred = EmailAuthProvider.credential(
                  email: user.email!,
                  password: oldPassController.text.trim(),
                );
                await user.reauthenticateWithCredential(cred);
                await user.updatePassword(newPassController.text.trim());
                Navigator.pop(context);
              } catch (e) {
                Navigator.pop(context);
                _showError(context, "Gagal update password: $e");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
            ),
            child: Text(
              "Simpan",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editPhoneDialog(BuildContext context) {
    final controller = TextEditingController(text: phoneNumber ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          "Ubah Nomor Telepon",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.phone_android, color: Colors.black),
            hintText: "Masukkan nomor telepon",
            hintStyle: GoogleFonts.poppins(
              color: Colors.black54,
            ),
            border: const OutlineInputBorder(),
          ),
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Batal",
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPhone = controller.text.trim();
              if (newPhone.isNotEmpty) {
                final uid = auth.currentUser!.uid;
                await FirebaseFirestore.instance
                    .collection('user')
                    .doc(uid)
                    .update({'phone': newPhone});
                setState(() => phoneNumber = newPhone);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
            ),
            child: Text(
              "Simpan",
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          "Konfirmasi",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF001F3D), // Navy
            fontSize: 18,
          ),
        ),
        content: Text(
          "Anda yakin ingin logout?",
          style: GoogleFonts.poppins(
            color: const Color(0xFF001F3D), // Navy
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Batal",
              style: GoogleFonts.poppins(
                color: const Color(0xFF001F3D), // Navy
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF001F3D), // Navy
            ),
            onPressed: () async {
              await auth.signOut();
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
            child: Text(
              "Logout",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          "Terjadi Kesalahan",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Tutup",
              style: GoogleFonts.poppins(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
