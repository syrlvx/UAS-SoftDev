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
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Gagal ambil data user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120), // Ukuran tinggi AppBar
        child: AppBar(
          title: Text("Akun Saya", style: TextStyle(color: Colors.white)),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF001F3D), // Biru navy gelap
                  Color(0xFFFFFFFF), // Putih
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
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
                      style: TextStyle(fontSize: 36, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    username ?? 'User',
                    style: TextStyle(
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
                  SizedBox(height: 20),
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
                                offset: Offset(0, -20)),
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 5,
                                spreadRadius: 1,
                                offset: Offset(2, 0)),
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 5,
                                spreadRadius: 1,
                                offset: Offset(-2, 0)),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(Icons.person_outline),
                                title: Text("Ubah Username"),
                                trailing: Icon(Icons.edit),
                                onTap: () => _editUsernameDialog(context),
                              ),
                              Divider(height: 1),
                              ListTile(
                                leading: Icon(Icons.email_outlined),
                                title: Text("Ubah Email"),
                                trailing: Icon(Icons.edit),
                                onTap: () => _editEmailDialog(context),
                              ),
                              Divider(height: 1),
                              ListTile(
                                leading: Icon(Icons.lock_outline),
                                title: Text("Ubah Password"),
                                trailing: Icon(Icons.edit),
                                onTap: () => _editPasswordDialog(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: Icon(Icons.logout),
                    label: Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text("Versi 1.0.0", style: TextStyle(color: Colors.grey)),
                  Text("© 2025 YourCompany",
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
        title: Text("Ubah Username"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              final newUsername = controller.text.trim();
              if (newUsername.isNotEmpty) {
                final uid = auth.currentUser!.uid;
                await FirebaseFirestore.instance
                    .collection('user')
                    .doc(uid)
                    .update({
                  'username': newUsername,
                });
                setState(() => username = newUsername);
                Navigator.pop(context);
              }
            },
            child: Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _editEmailDialog(BuildContext context) {
    final controller = TextEditingController(text: email ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Ubah Email"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(border: OutlineInputBorder()),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              try {
                await auth.currentUser?.updateEmail(controller.text.trim());
                setState(() => email = controller.text.trim());
                Navigator.pop(context);
              } catch (e) {
                Navigator.pop(context);
                _showError(context, "Gagal update email: $e");
              }
            },
            child: Text("Simpan"),
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
        title: Text("Ubah Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassController,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: "Password Lama", border: OutlineInputBorder()),
            ),
            SizedBox(height: 12),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: "Password Baru", border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              try {
                final user = auth.currentUser!;
                final cred = EmailAuthProvider.credential(
                    email: user.email!,
                    password: oldPassController.text.trim());
                await user.reauthenticateWithCredential(cred);
                await user.updatePassword(newPassController.text.trim());
                Navigator.pop(context);
              } catch (e) {
                Navigator.pop(context);
                _showError(context, "Gagal update password: $e");
              }
            },
            child: Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Konfirmasi"),
        content: Text("Anda yakin ingin logout?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              await auth.signOut();
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => LoginScreen()));
            },
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Terjadi Kesalahan"),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Tutup"))
        ],
      ),
    );
  }
}
