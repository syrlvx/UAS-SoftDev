import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:purelux/screens/login_screen.dart';

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
            isLoading = false;
          });
        }
      }
    } catch (e) {
      _showError(context, "Gagal mengambil data: $e");
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
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue.shade700,
                    child: Text(
                      (username?.isNotEmpty == true)
                          ? username![0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontSize: 36, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    username ?? 'User',
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    email ?? 'user@example.com',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  if (phoneNumber != null && phoneNumber!.isNotEmpty)
                    Text(
                      phoneNumber!,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 20),
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
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.person_outline),
                                title: const Text("Ubah Username"),
                                trailing: const Icon(Icons.edit),
                                onTap: () => _editUsernameDialog(context),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.lock_outline),
                                title: const Text("Ubah Password"),
                                trailing: const Icon(Icons.edit),
                                onTap: () => _editPasswordDialog(context),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.phone_android),
                                title: const Text("Ubah No Telepon"),
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
                    label: const Text("Logout",
                        style: TextStyle(color: Colors.white)),
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
                  const Text("Versi 1.0.0",
                      style: TextStyle(color: Colors.grey)),
                  const Text("© 2025 PureLux",
                      style: TextStyle(color: Colors.grey)),
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
        title: const Text(
          "Ubah Username",
          style: TextStyle(color: Colors.black),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.person_outline, color: Color(0xFF001F3D)),
            hintText: "Masukkan username baru",
            hintStyle: TextStyle(color: Color(0xFF001F3D)),
            border: OutlineInputBorder(),
          ),
          style: const TextStyle(color: Color(0xFF001F3D)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("Batal", style: TextStyle(color: Color(0xFF001F3D))),
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
              backgroundColor: Color(0xFF001F3D),
            ),
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
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
        title: const Text("Ubah Password",
            style: TextStyle(color: Color(0xFF001F3D))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassController,
              obscureText: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock_outline, color: Colors.black),
                labelText: "Password Lama",
                labelStyle: TextStyle(color: Colors.black54),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock_open, color: Colors.black),
                labelText: "Password Baru",
                labelStyle: TextStyle(color: Colors.black54),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.black)),
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
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
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
        title: const Text(
          "Ubah Nomor Telepon",
          style: TextStyle(color: Colors.black),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.phone_android, color: Colors.black),
            hintText: "Masukkan nomor telepon",
            hintStyle: TextStyle(color: Colors.black54),
            border: OutlineInputBorder(),
          ),
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.black)),
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
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
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
              title: const Text(
                "Konfirmasi",
                style: TextStyle(color: Color(0xFF001F3D)), // Navy
              ),
              content: const Text(
                "Anda yakin ingin logout?",
                style: TextStyle(color: Color(0xFF001F3D)), // Navy
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Batal",
                    style: TextStyle(color: Color(0xFF001F3D)), // Navy
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF001F3D), // Navy
                  ),
                  onPressed: () async {
                    await auth.signOut();
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  },
                  child: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ));
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Terjadi Kesalahan"),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"))
        ],
      ),
    );
  }
}
