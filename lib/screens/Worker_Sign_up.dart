import 'dart:io';
import 'dart:convert'; // Untuk mengubah file jadi Base64
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:shared_preferences/shared_preferences.dart'; // 1. WAJIB IMPORT INI

import 'package:flutter_application_1/screens/dashboard_screen.dart';
import '../widgets/double_wave_header.dart';

class WorkerSignUpScreen extends StatefulWidget {
  const WorkerSignUpScreen({super.key});

  @override
  State<WorkerSignUpScreen> createState() => _WorkerSignUpScreenState();
}

class _WorkerSignUpScreenState extends State<WorkerSignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  File? _cvFile;
  String? cvFileName;
  bool _isLoading = false; // Status Loading

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    educationController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // --- FUNGSI PILIH FILE (DENGAN CEK PRIVASI) ---
  Future<void> _pickCVFile() async {
    // 1. CEK SAKLAR PRIVASI DULU
    final prefs = await SharedPreferences.getInstance();
    // Ambil status 'privacy_data' (sesuai yang diset di PrivasiPage)
    bool isDataAllowed = prefs.getBool('privacy_data') ?? true;

    // 2. JIKA DIMATIKAN, STOP PROSES
    if (!isDataAllowed) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin akses data dimatikan di menu Privasi.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return; // Berhenti di sini, File Picker tidak akan terbuka
    }

    // 3. JIKA DIIZINKAN, LANJUT BUKA FILE PICKER
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        // Cek ukuran file (Maksimal 1 MB agar aman di Firestore)
        File file = File(result.files.single.path!);
        int sizeInBytes = await file.length();
        double sizeInMb = sizeInBytes / (1024 * 1024);

        if (sizeInMb > 1.0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ukuran file terlalu besar (Maks 1MB)'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _cvFile = file;
          cvFileName = result.files.single.name;
        });

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('CV berhasil dipilih')));
        }
      }
    } on PlatformException catch (e) {
      debugPrint("Error Permission: $e");
    } catch (e) {
      debugPrint("Error Pick File: $e");
    }
  }

  // --- FUNGSI DAFTAR RELAWAN (UPDATE: DENGAN NOTIFIKASI OTOMATIS) ---
  Future<void> _submitVolunteer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cvFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wajib upload CV (PDF/Word)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Convert File
      List<int> fileBytes = await _cvFile!.readAsBytes();
      String base64File = base64Encode(fileBytes);

      // A. SIMPAN DATA RELAWAN (SEPERTI BIASA)
      await FirebaseFirestore.instance.collection('pendaftaran_relawan').add({
        'uid': user.uid,
        'email_akun': user.email,
        'nama_lengkap': nameController.text,
        'tgl_lahir': dobController.text,
        'pendidikan': educationController.text,
        'no_hp': phoneController.text,
        'email_kontak': emailController.text,
        'nama_file_cv': cvFileName,
        'file_cv_base64': base64File,
        'tgl_daftar': FieldValue.serverTimestamp(),
        'status': 'Menunggu Review',
      });

      // B. (BARU) BUAT NOTIFIKASI OTOMATIS
      await FirebaseFirestore.instance.collection('notifikasi').add({
        'uid_user': user.uid,
        'judul': 'Pendaftaran Sukarelawan',
        'sub_judul': 'Berkas Diterima',
        'pesan':
            'Halo ${nameController.text}, berkas pendaftaranmu sebagai sukarelawan sudah kami terima. Harap menunggu proses seleksi selanjutnya.',
        'tipe': 'info', // Warna Biru
        'tanggal': FieldValue.serverTimestamp(),
        'is_read': false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pendaftaran Berhasil Dikirim!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset Form
        nameController.clear();
        dobController.clear();
        educationController.clear();
        phoneController.clear();
        emailController.clear();
        setState(() {
          _cvFile = null;
          cvFileName = null;
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Dashboard()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendaftar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 150.0;
    const double horizontalPadding = 24.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Stack(
        children: [
          const SizedBox(
            height: headerHeight,
            width: double.infinity,
            child: DoubleWaveHeader(),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                horizontalPadding,
                headerHeight - 60,
                horizontalPadding,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50, bottom: 12),
                    child: Text(
                      "Mendaftar Sukarelawan",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4894FE),
                        shadows: const [
                          Shadow(
                            offset: Offset(1, 3),
                            blurRadius: 3,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: "Nama",
                            prefixIcon: const Icon(Icons.person_outline),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (val) =>
                              val!.isEmpty ? "Wajib diisi" : null,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: dobController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Tanggal lahir",
                            prefixIcon: const Icon(
                              Icons.calendar_today_outlined,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.date_range),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime(2000),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() {
                                    dobController.text =
                                        "${picked.day}/${picked.month}/${picked.year}";
                                  });
                                }
                              },
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (val) =>
                              val!.isEmpty ? "Wajib diisi" : null,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: educationController,
                          decoration: InputDecoration(
                            labelText: "Pendidikan",
                            prefixIcon: const Icon(Icons.school_outlined),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (val) =>
                              val!.isEmpty ? "Wajib diisi" : null,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: "Nomor telepon",
                            prefixIcon: const Icon(Icons.phone_outlined),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (val) =>
                              val!.isEmpty ? "Wajib diisi" : null,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (val) => (!val!.contains('@'))
                              ? "Email tidak valid"
                              : null,
                        ),
                        const SizedBox(height: 18),

                        // --- TOMBOL UPLOAD (DENGAN CEK PRIVASI) ---
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed:
                                  _pickCVFile, // Panggil fungsi yang sudah dimodifikasi
                              icon: const Icon(
                                Icons.upload_file,
                                color: Color(0xFF4894FE),
                              ),
                              label: const Text(
                                "Upload CV",
                                style: TextStyle(
                                  color: Color(0xFF4894FE),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD9EAFD),
                                minimumSize: const Size(120, 44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cvFileName ?? "Format: PDF/Doc (Max 1MB)",
                                    style: TextStyle(
                                      color: _cvFile != null
                                          ? Colors.black87
                                          : Colors.black54,
                                      fontWeight: _cvFile != null
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (_cvFile != null)
                                    const Text(
                                      "Siap diunggah",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.green,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (_cvFile != null)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitVolunteer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD9EAFD),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 4,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Mendaftar",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4894FE),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const Dashboard()),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
