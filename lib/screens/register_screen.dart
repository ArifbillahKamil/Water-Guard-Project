import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../widgets/double_wave_header.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // State
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool _isLoading = false; // Untuk loading button

  @override
  void dispose() {
    usernameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // --- FUNGSI REGISTER ---
  Future<void> _registerUser() async {
    // 1. Cek Validasi Form
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 2. Buat Akun di Firebase Authentication
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // Ambil UID user yang baru dibuat
      String uid = userCredential.user!.uid;

      // 3. Simpan Biodata Tambahan ke Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'role': 'user', // Default role
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // 4. Sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi Berhasil! Silakan Masuk.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Kembali ke Login Screen
      }
    } on FirebaseAuthException catch (e) {
      // Handle Error Firebase
      String message = "Terjadi kesalahan.";
      if (e.code == 'weak-password') {
        message = "Password terlalu lemah (minimal 8 karakter).";
      } else if (e.code == 'email-already-in-use') {
        message = "Email ini sudah terdaftar.";
      } else if (e.code == 'invalid-email') {
        message = "Format email salah.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ===== Double Wave Header =====
            const SizedBox(
              height: 150, // Pastikan ada tinggi agar header muncul
              child: DoubleWaveHeader(),
            ),

            // ===== Judul "Mendaftar" =====
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 16),
              child: Text(
                "Mendaftar",
                style: TextStyle(
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

            // ===== Form Register =====
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Username
                    TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: "Nama pengguna",
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Nama wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Nomor telepon",
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Nomor telepon wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Email wajib diisi";
                        if (!value.contains('@')) return "Format email salah";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: passwordController,
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
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Sandi wajib diisi";
                        if (value.length < 8) return "Sandi minimal 8 karakter";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: "Ulangi sandi",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword = !obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Ulangi sandi wajib diisi";
                        if (value != passwordController.text)
                          return "Sandi tidak sama";
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // ===== Tombol Daftar =====
                    ElevatedButton(
                      onPressed: _isLoading ? null : _registerUser,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        backgroundColor: const Color(0xFFD9EAFD), // biru muda
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
                              "Mendaftar",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4894FE), // biru utama
                              ),
                            ),
                    ),

                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Kembali ke Login
                        },
                        child: const Text.rich(
                          TextSpan(
                            text: "Sudah memiliki akun? ",
                            children: [
                              TextSpan(
                                text: "Masuk",
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

                    // Tombol sosial media
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

                        // X / Twitter
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          child: Icon(
                            FontAwesomeIcons.xTwitter,
                            color: Colors.black,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
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
