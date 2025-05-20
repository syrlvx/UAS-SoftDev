import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:purelux/firebase_options.dart';
import 'package:purelux/widgets/bottom_nav_bar.dart';
import 'package:purelux/widgets/bottom_nav_bar_admin.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error initializing Firebase: $e');
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;
      // ignore: avoid_print
      print('UID: $uid');

      // Simpan OneSignal playerId ke Firestore
      String? playerId = OneSignal.User.pushSubscription.id;
      if (playerId != null) {
        await FirebaseFirestore.instance
            .collection('user')
            .doc(uid)
            .update({'onesignalPlayerId': playerId});
      }

      final userDoc =
          await FirebaseFirestore.instance.collection('user').doc(uid).get();

      if (!userDoc.exists || !userDoc.data()!.containsKey('role')) {
        throw FirebaseAuthException(
            code: 'no-role', message: 'Role is not set for this user.');
      }

      final role = userDoc['role'];

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavBarAdmin()),
        );
      } else if (role == 'karyawan') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavBar()),
        );
      } else {
        throw FirebaseAuthException(
            code: 'invalid-role', message: 'Unknown role: $role');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password.';
      } else {
        errorMessage = e.message ?? 'An error occurred during login.';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Failed'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih
      appBar: AppBar(
        toolbarHeight: 120,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Color(0xFF001F3D), // Biru navy gelap
              Color(0xFFFFFFFF), // Putih
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26, // lebih besar
            fontWeight: FontWeight.bold, // lebih tebal
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 50),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, color: Colors.black),
                ),
                style: const TextStyle(color: Colors.black),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(
                          r"^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$")
                      .hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock, color: Colors.black),
                ),
                style: const TextStyle(color: Colors.black),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 80),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF001F3D), // Biru navy gelap
                            Color(0xFFFFFFFF),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.transparent, // Membuat tombol transparan
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          side:
                              BorderSide.none, // Menghilangkan border jika ada
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Teks tombol berwarna putih
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
