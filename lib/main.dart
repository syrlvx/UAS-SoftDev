import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:purelux/firebase_options.dart'; // Pastikan ini sesuai dengan path file yang dihasilkan
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purelux/screens/splash_screen.dart';
import 'package:purelux/widgets/bottom_nav_bar.dart';
import 'package:purelux/widgets/bottom_nav_bar_admin.dart';
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
          String uid = snapshot.data!.uid;
          return FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance.collection('user').doc(uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  !snapshot.data!.exists) {
                return const Center(
                    child: Text("Terjadi kesalahan atau data tidak ditemukan"));
              }

              final userData = snapshot.data!;
              final role = userData['role'] ?? '';

              globals.uid = userData.id;
              globals.nama = userData['username'] ?? '';

              if (role == 'admin') {
                return BottomNavBarAdmin(); // Ganti dengan screen admin
              } else if (role == 'karyawan') {
                return BottomNavBar();
              } else {
                return const Center(child: Text("Role tidak dikenali"));
              }
            },
          );
        } else {
          return SplashScreen();
        }
      },
    );
  }
}
