import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:purelux/firebase_options.dart'; // Pastikan ini sesuai dengan path file yang dihasilkan
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purelux/screens/login_screen.dart';
import 'package:purelux/screens/splash_screen.dart';
import 'package:purelux/widgets/bottom_nav_bar.dart';
import 'package:purelux/widgets/bottom_nav_bar_admin.dart';
import 'screens/globals.dart' as globals; // Import file globals.dart
import 'package:intl/date_symbol_data_local.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize OneSignal
  OneSignal.initialize('f15e15fd-ac05-4fa8-a0d8-56d22546a3cf');
  OneSignal.Notifications.requestPermission(true);

  await supabase.Supabase.initialize(
    url:
        'https://zmxqbmzpmwpouhgxoala.supabase.co', // Ganti dengan URL project kamu
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpteHFibXpwbXdwb3VoZ3hvYWxhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc0ODEyMzMsImV4cCI6MjA2MzA1NzIzM30.YOVx6Eh5hqnMZO4zNSa8KiI8BS7ZxoAA23_tGu8o8kM', // Ganti dengan anon key project kamu
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'PureLux',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        primaryColor: Colors.white,
        popupMenuTheme: const PopupMenuThemeData(color: Colors.white),
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          bodyLarge: const TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
          bodyMedium: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 193, 64, 127),
        ).copyWith(surface: Colors.black),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        MonthYearPickerLocalizations.delegate, // PENTING
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('id'), // Tambahkan jika ingin dukung Bahasa Indonesia
      ],

      // Home screen tergantung status login
      home: const SplashScreen(),
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
          return LoginScreen();
        }
      },
    );
  }
}
