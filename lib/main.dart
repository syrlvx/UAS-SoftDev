import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:purelux/firebase_options.dart'; // Pastikan ini sesuai dengan path file yang dihasilkan
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purelux/screens/splash_screen.dart';
import 'package:purelux/widgets/bottom_nav_bar.dart';
import 'screens/globals.dart' as globals; // Import file globals.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Pastikan menggunakan FirebaseOptions yang benar
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PureLux',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
          bodyMedium: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        fontFamily: GoogleFonts.ptSans().fontFamily,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 193, 64, 127))
            .copyWith(surface: Colors.black),
      ),
      // Home screen tergantung status login
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          // Jika pengguna sudah login
          String uid = snapshot.data!.uid; // Ambil UID pengguna yang login
          _fetchUserData(uid); // Ambil data pengguna dari Firestore

          return BottomNavBar(); // Ganti dengan tampilan setelah login (misal: BottomNavBar)
        } else {
          return SplashScreen(); // Tampilkan SplashScreen jika belum login
        }
      },
    );
  }

  // Ambil data pengguna dari Firestore berdasarkan UID
  Future<void> _fetchUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user') // Pastikan koleksi 'user' ada di Firestore
          .doc(uid)
          .get();

      if (userDoc.exists) {
        globals.uid = userDoc.id;
        globals.nama =
            userDoc['username']; // Ambil nama pengguna dari field 'username'
        print(
            'Username: ${globals.nama}'); // Tampilkan nama pengguna di console atau simpan di state/global
      } else {
        print("Dokumen pengguna tidak ditemukan");
      }
    } catch (e) {
      print("Terjadi kesalahan saat mengambil data pengguna: $e");
    }
  }
}
