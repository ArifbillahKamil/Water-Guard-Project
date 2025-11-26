import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '../widgets/double_wave_header.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>(); // Key untuk validasi form
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false; // Status loading

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // --- FUNGSI RESET PASSWORD ---
  Future<void> _resetPassword() async {
    // 1. Cek apakah email sudah diisi dengan benar?
    if (!_formKey.currentState!.validate()) return;

    // 2. Nyalakan loading dan tutup keyboard
    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      // 3. Panggil Fungsi Firebase Reset Password
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      if (mounted) {
        // 4. Jika sukses, tampilkan pesan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tautan reset telah dikirim ke email Anda.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );

        // Kembali ke halaman Login setelah sukses
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      // 5. Tangani Error (Misal email tidak terdaftar)
      String message = "Terjadi kesalahan.";
      if (e.code == 'user-not-found') {
        message = "Email tidak terdaftar.";
      } else if (e.code == 'invalid-email') {
        message = "Format email salah.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      // 6. Matikan loading
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Agar layout naik saat keyboard muncul
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== Wave Header =====
            const SizedBox(
              height: 200,
              child: DoubleWaveHeader(), // Pastikan tinggi sesuai widget kamu
            ),

            // ===== Icon dan Judul =====
            const Column(
              children: [
                Icon(Icons.lock_reset, size: 80, color: Color(0xFF4894FE)),
                SizedBox(height: 8),
                Text(
                  "Lupa Kata Sandi",
                  style: TextStyle(
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
                key: _formKey, // Pasang key form di sini
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Masukkan email akun Anda untuk mengatur ulang kata sandi.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    // Input Email (Ganti TextField jadi TextFormField)
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email wajib diisi";
                        }
                        if (!value.contains('@')) {
                          return "Format email tidak valid";
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
                          : const Text(
                              "Kirim Tautan Reset",
                              style: TextStyle(
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
                // Kembali ke halaman sebelumnya (Login) dengan pop
                // Lebih baik pop daripada pushReplacement agar animasi natural
                Navigator.pop(context);
              },
              child: const Text(
                "Kembali ke halaman masuk",
                style: TextStyle(
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
