import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. WAJIB IMPORT INI
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
  bool _isLoading = false;

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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Buat Akun Firebase
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      String uid = userCredential.user!.uid;

      // Simpan Biodata ke Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'role': 'user',
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("msg_reg_success".tr()), // Translate Pesan Sukses
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message = "msg_general_error".tr();

      // Translate Pesan Error Firebase
      if (e.code == 'weak-password') {
        message = "msg_weak_pass".tr();
      } else if (e.code == 'email-already-in-use') {
        message = "msg_email_used".tr();
      } else if (e.code == 'invalid-email') {
        message = "err_email_invalid".tr();
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
            const SizedBox(height: 150, child: DoubleWaveHeader()),

            // ===== Judul =====
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Text(
                "reg_title".tr(), // Translate Judul
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
                      decoration: InputDecoration(
                        labelText: "reg_username".tr(), // Translate Label
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (value) => value!.isEmpty
                          ? "err_username".tr()
                          : null, // Translate Error
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "reg_phone".tr(),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "err_phone".tr() : null,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "reg_email".tr(),
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "err_email_empty".tr();
                        if (!value.contains('@'))
                          return "err_email_invalid".tr();
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: "reg_pass".tr(),
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
                          return "err_pass_empty".tr();
                        if (value.length < 8) return "err_pass_short".tr();
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: "reg_confirm_pass".tr(),
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
                          return "err_confirm_empty".tr();
                        if (value != passwordController.text)
                          return "err_confirm_match".tr();
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
                              "reg_btn".tr(), // Translate Tombol
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4894FE),
                              ),
                            ),
                    ),

                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text.rich(
                          TextSpan(
                            text: "reg_have_account"
                                .tr(), // "Sudah punya akun?"
                            children: [
                              TextSpan(
                                text: "reg_login".tr(), // "Masuk"
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
                          child: Text("reg_or".tr()), // "Atau"
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tombol Sosial Media (Tetap sama karena Icon)
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
