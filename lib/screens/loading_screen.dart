import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    // Simulasi loading sebelum ke halaman berikutnya
    Future.delayed(const Duration(seconds: 4), () {
      // Navigator.pushReplacementNamed(context, '/home'); // aktifkan jika sudah punya route
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5CA2FF), // Biru di atas
              Color(0xFFB9FFB3), // Hijau muda di bawah
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              "Water Guard",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                letterSpacing: 1,
                fontWeight: FontWeight.w400,
                fontFamily:
                    'Pacifico', // Jika ingin font khusus, pastikan sudah didaftarkan di pubspec.yaml
              ),
            ),
          ),
        ),
      ),
    );
  }
}
