import 'dart:io';
import 'dart:convert'; // Wajib untuk Base64
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/screens/dashboard_screen.dart';
import '../widgets/double_wave_header.dart'; // Pastikan path ini sesuai dengan projectmu

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
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    educationController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // --- FUNGSI PILIH FILE (DENGAN PENGECEKAN KETAT) ---
  Future<void> _pickCVFile() async {
    final prefs = await SharedPreferences.getInstance();
    bool isDataAllowed = prefs.getBool('privacy_data') ?? true;

    if (!isDataAllowed) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin akses data dimatikan di menu Privasi.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        int sizeInBytes = await file.length();
        double sizeInKb = sizeInBytes / 1024;

        // [PENGECEKAN 1] Tolak jika file kosong (0 byte)
        if (sizeInBytes == 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'File kosong (0 bytes)! Silakan pilih file lain.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // [PENGECEKAN 2] Tolak jika file > 500 KB
        if (sizeInKb > 500) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File terlalu besar! Maksimal 500 KB.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('CV berhasil dipilih (Valid)'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } on PlatformException catch (e) {
      debugPrint("Error Permission: $e");
    } catch (e) {
      debugPrint("Error Pick File: $e");
    }
  }

  // --- FUNGSI DAFTAR (DENGAN VALIDASI DATA FILE) ---
  Future<void> _submitVolunteer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cvFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wajib upload CV'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // 1. BACA FILE MENJADI BYTES
      List<int> fileBytes = await _cvFile!.readAsBytes();

      // [PENGECEKAN 3] Pastikan hasil bacaan tidak kosong
      if (fileBytes.isEmpty) {
        throw Exception("Gagal membaca file (File kosong/rusak).");
      }

      // 2. KONVERSI KE BASE64 STRING
      String base64File = base64Encode(fileBytes);

      // [PENGECEKAN 4] Pastikan hasil konversi string ada isinya
      if (base64File.isEmpty) {
        throw Exception("Gagal mengonversi file ke teks.");
      }

      // Debugging: Cek panjang string di console
      debugPrint(
        "Info File: Nama=$cvFileName, Panjang Base64=${base64File.length}",
      );

      // 3. SIMPAN KE FIRESTORE
      await FirebaseFirestore.instance.collection('pendaftaran_relawan').add({
        'uid': user.uid,
        'email_akun': user.email,
        'nama_lengkap': nameController.text,
        'tgl_lahir': dobController.text,
        'pendidikan': educationController.text,
        'no_hp': phoneController.text,
        'email_kontak': emailController.text,
        'nama_file_cv': cvFileName,

        // FIELD UTAMA: Pastikan variabel ini yang dikirim
        'file_cv_base64': base64File,

        'tgl_daftar': FieldValue.serverTimestamp(),
        'status': 'Menunggu Review',
      });

      // 4. BUAT NOTIFIKASI
      await FirebaseFirestore.instance.collection('notifikasi').add({
        'uid_user': user.uid,
        'judul': 'Pendaftaran Sukarelawan',
        'sub_judul': 'Berkas Diterima',
        'pesan': 'Halo ${nameController.text}, berkasmu aman diterima sistem.',
        'tipe': 'info',
        'tanggal': FieldValue.serverTimestamp(),
        'is_read': false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sukses Mendaftar!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset Form
        nameController.clear();
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
      debugPrint("Error Submit: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal Mendaftar: $e'),
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
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 50, bottom: 12),
                    child: Text(
                      "Mendaftar Sukarelawan",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4894FE),
                      ),
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          nameController,
                          "Nama",
                          Icons.person_outline,
                        ),
                        const SizedBox(height: 12),
                        _buildDateField(context),
                        const SizedBox(height: 12),
                        _buildTextField(
                          educationController,
                          "Pendidikan",
                          Icons.school_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          phoneController,
                          "Nomor telepon",
                          Icons.phone_outlined,
                          isPhone: true,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          emailController,
                          "Email",
                          Icons.email_outlined,
                          isEmail: true,
                        ),
                        const SizedBox(height: 18),

                        // --- TOMBOL UPLOAD ---
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickCVFile,
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
                                    cvFileName ?? "PDF/Doc/Img (<500KB)",
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
                                      "Siap dikirim",
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

                        // --- TOMBOL DAFTAR ---
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
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPhone = false,
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isPhone
          ? TextInputType.phone
          : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return "Wajib diisi";
        if (isEmail && !val.contains('@')) return "Email tidak valid";
        return null;
      },
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextFormField(
      controller: dobController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: "Tanggal lahir",
        prefixIcon: const Icon(Icons.calendar_today_outlined),
        suffixIcon: const Icon(Icons.date_range),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(
            () => dobController.text =
                "${picked.day}/${picked.month}/${picked.year}",
          );
        }
      },
      validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
    );
  }
}
