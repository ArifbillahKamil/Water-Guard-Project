import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/dashboard_screen.dart';
import 'package:flutter_application_1/screens/forgot_password.dart';
import 'package:flutter_application_1/screens/register_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/double_wave_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ===== Double Wave Header =====
            const DoubleWaveHeader(),

            // ===== Judul "Masuk" =====
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 16),
              child: Text(
                "Masuk",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4894FE), // biru utama
                  shadows: [
                    Shadow(
                      offset: Offset(1, 4),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ),

            // ===== Form Login =====
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Username / Email
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Nama pengguna / Email",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextField(
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Sandi",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Ingat saya + lupa sandi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (value) {
                              setState(() {
                                rememberMe = value ?? false;
                              });
                            },
                          ),
                          const Text("Ingat saya"),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text("Lupa sandi?"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ===== Tombol Masuk =====
                  ElevatedButton(
                    onPressed: () {
                      // tutup keyboard kalau terbuka
                      FocusScope.of(context).unfocus();
                      // navigasi ke Dashboard, menggantikan layar login
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const Dashboard()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      backgroundColor: const Color(0xFFD9EAFD),
                    ),
                    child: const Text(
                      "Masuk",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4894FE),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===== Navigasi ke register =====
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text.rich(
                        TextSpan(
                          text: "Tidak memiliki akun? ",
                          children: [
                            TextSpan(
                              text: "Mendaftar",
                              style: TextStyle(
                                color: Color(0xFF4894FE),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text("Atau"),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ===== Tombol sosial media =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: Icon(
                          FontAwesomeIcons.google,
                          size: 28,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Facebook
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: Icon(
                          FontAwesomeIcons.facebookF,
                          color: Colors.blue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Apple
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: Icon(
                          FontAwesomeIcons.apple,
                          color: Colors.black,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
