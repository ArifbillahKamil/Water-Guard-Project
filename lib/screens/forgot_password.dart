import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. WAJIB IMPORT INI
import '../widgets/double_wave_header.dart';
// import 'login_screen.dart'; // Tidak wajib jika pakai pop

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // --- FUNGSI RESET PASSWORD ---
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("msg_reset_sent".tr()), // "Tautan dikirim..."
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message = "msg_general_error".tr(); // Default error

      if (e.code == 'user-not-found') {
        message = "err_email_not_found".tr(); // "Email tidak terdaftar"
      } else if (e.code == 'invalid-email') {
        message = "err_email_fmt".tr(); // "Format email salah"
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
          children: [
            // ===== Wave Header =====
            const SizedBox(height: 200, child: DoubleWaveHeader()),

            // ===== Icon dan Judul =====
            Column(
              children: [
                const Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: Color(0xFF4894FE),
                ),
                const SizedBox(height: 8),
                Text(
                  "forgot_title".tr(), // "Lupa Kata Sandi"
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4894FE),
                    shadows: [
                      Shadow(
                        offset: Offset(1, 2),
                        blurRadius: 2,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ===== Form Input =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "forgot_desc".tr(), // Deskripsi instruksi
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Input Email
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "login_email_label"
                            .tr(), // Pakai label email dari Login
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "err_email_req".tr(); // "Email wajib diisi"
                        }
                        if (!value.contains('@')) {
                          return "err_email_fmt".tr(); // "Format email salah"
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Tombol Kirim Reset
                    ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
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
                              "forgot_btn".tr(), // "Kirim Tautan Reset"
                              style: const TextStyle(
                                color: Color(0xFF4894FE),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ===== Navigasi Kembali =====
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text(
                "forgot_back_login".tr(), // "Kembali ke halaman masuk"
                style: const TextStyle(
                  color: Color(0xFF4894FE),
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
