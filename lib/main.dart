import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';

import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/dashboard_screen.dart';
import 'package:flutter_application_1/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('id'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('id'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WaterGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      // 1. Saat pertama buka, tampilkan SplashScreen
      home: const SplashScreen(),
    );
  }
}

// ==========================================
// WIDGET PENGECEKAN STATUS LOGIN & WAKTU
// ==========================================
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  Future<bool> _checkInactivity() async {
    final prefs = await SharedPreferences.getInstance();

    int? lastOpened = prefs.getInt('last_opened_timestamp');
    int now = DateTime.now().millisecondsSinceEpoch;

    // 1 Bulan (30 Hari)
    const int oneMonthInMs = 30 * 24 * 60 * 60 * 1000;

    if (lastOpened != null) {
      if ((now - lastOpened) > oneMonthInMs) {
        return true; // Harus Logout
      }
    }

    await prefs.setInt('last_opened_timestamp', now);
    return false; // Aman
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading saat cek Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // A. JIKA ADA USER YANG LOGIN
        if (snapshot.hasData) {
          return FutureBuilder<bool>(
            future: _checkInactivity(),
            builder: (context, inactivitySnapshot) {
              if (inactivitySnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              bool shouldLogout = inactivitySnapshot.data ?? false;

              if (shouldLogout) {
                // JIKA SUDAH 1 BULAN -> PAKSA LOGOUT & KE LOGIN
                FirebaseAuth.instance.signOut();
                return const LoginScreen();
              } else {
                // JIKA AMAN -> MASUK DASHBOARD
                return const Dashboard();
              }
            },
          );
        }

        // B. JIKA TIDAK ADA USER (Belum Login)
        return const LoginScreen();
      },
    );
  }
}
