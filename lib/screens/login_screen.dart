import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/dashboard_screen.dart';
import 'package:flutter_application_1/screens/forgot_password.dart';
import 'package:flutter_application_1/screens/register_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. WAJIB IMPORT INI
import '../widgets/double_wave_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Key untuk Validasi Form
  final _formKey = GlobalKey<FormState>();

  // Controller untuk mengambil teks
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool rememberMe = false;
  bool obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- FUNGSI LOGIN ---
  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Dashboard()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "err_login_failed".tr(); // Translate Judul Error

      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        message = "err_invalid_cred".tr();
      } else if (e.code == 'invalid-email') {
        message = "err_email_fmt".tr();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ===== Double Wave Header =====
            const SizedBox(height: 150, child: DoubleWaveHeader()),

            // ===== Judul "Masuk" =====
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Text(
                "login_header".tr(), // Translate Judul
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4894FE),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Username / Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "login_email_label".tr(), // Translate Label
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "err_email_req".tr(); // Translate Error
                        }
                        if (!value.contains('@')) {
                          return "err_email_fmt".tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: "login_pass_label".tr(), // Translate Label
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "err_pass_req".tr(); // Translate Error
                        }
                        return null;
                      },
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
                            Text(
                              "login_remember".tr(),
                            ), // Translate "Ingat saya"
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
                          child: Text(
                            "login_forgot".tr(),
                          ), // Translate "Lupa sandi?"
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ===== Tombol Masuk =====
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              FocusScope.of(context).unfocus();
                              _loginUser();
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        backgroundColor: const Color(0xFFD9EAFD),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF4894FE),
                              ),
                            )
                          : Text(
                              "login_btn".tr(), // Translate Tombol
                              style: const TextStyle(
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
                        child: Text.rich(
                          TextSpan(
                            text: "login_no_account"
                                .tr(), // "Tidak punya akun?"
                            children: [
                              TextSpan(
                                text: "login_register".tr(), // "Mendaftar"
                                style: const TextStyle(
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
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text("login_or".tr()), // "Atau"
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ===== Tombol sosial media (Tetap) =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
            ),
          ],
        ),
      ),
    );
  }
}
