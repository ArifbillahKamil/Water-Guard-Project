import 'dart:io';
import 'dart:convert'; // Untuk Base64
import 'dart:typed_data'; // Untuk decoding gambar

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // Import Image Picker

import 'package:flutter_application_1/screens/profile_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String _email = "Loading...";
  String? _selectedGender;

  // --- VARIABEL FOTO ---
  File? _newImageFile; // Foto baru yang dipilih dari galeri
  String? _currentImageBase64; // Foto lama dari database (String Base64)

  bool _isEditing = false;
  bool _isLoading = false;

  final List<String> _genderOptions = ['Laki-laki', 'Perempuan'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // --- 1. AMBIL DATA & FOTO DARI FIREBASE ---
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

          setState(() {
            _email = user.email ?? "-";
            nameController.text = data['username'] ?? "";
            phoneController.text = data['phone'] ?? "";
            birthController.text = data['tgl_lahir'] ?? "";

            if (_genderOptions.contains(data['gender'])) {
              _selectedGender = data['gender'];
            }

            // Ambil string foto jika ada
            _currentImageBase64 = data['profile_image_base64'];
          });
        }
      } catch (e) {
        debugPrint("Gagal load profile: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  // --- 2. FUNGSI GANTI FOTO ---
  Future<void> _pickImage() async {
    if (!_isEditing) return; // Hanya bisa ganti foto pas mode edit

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 20, // KOMPRESI KUAT SUPAYA RINGAN DI DATABASE
      );

      if (pickedFile != null) {
        setState(() {
          _newImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Gagal ambil foto: $e");
    }
  }

  // --- 3. SIMPAN DATA & FOTO ---
  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Siapkan data dasar
        Map<String, dynamic> dataToUpdate = {
          'username': nameController.text,
          'phone': phoneController.text,
          'tgl_lahir': birthController.text,
          'gender': _selectedGender,
          'email': user.email,
          'updated_at': FieldValue.serverTimestamp(),
        };

        // Jika user memilih foto baru, konversi ke Base64 dan masukkan ke data
        if (_newImageFile != null) {
          Uint8List imageBytes = await _newImageFile!.readAsBytes();
          String base64String = base64Encode(imageBytes);
          dataToUpdate['profile_image_base64'] = base64String;

          // Update variable lokal biar langsung berubah
          _currentImageBase64 = base64String;
          _newImageFile = null; // Reset file sementara
        }

        // Simpan ke Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(dataToUpdate, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil disimpan!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() => _isEditing = false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
    setState(() => _isLoading = false);
  }

  // Helper Date Picker
  Future<void> _selectDate() async {
    if (!_isEditing) return;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        birthController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // Widget Input
  Widget labeledField({
    required String label,
    required TextEditingController controller,
    bool isReadOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            readOnly: isReadOnly,
            onTap: onTap,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: isReadOnly ? const Color(0xFFF0F0F0) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isReadOnly
                      ? Colors.transparent
                      : const Color(0xFFE5E5E5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF4894FE),
                  width: 1.6,
                ),
              ),
              suffixIcon: suffixIcon,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- LOGIKA MENENTUKAN GAMBAR APA YANG DITAMPILKAN ---
    ImageProvider? imageProvider;
    if (_newImageFile != null) {
      // 1. Prioritas: Foto baru yang belum disimpan (File)
      imageProvider = FileImage(_newImageFile!);
    } else if (_currentImageBase64 != null && _currentImageBase64!.isNotEmpty) {
      // 2. Prioritas: Foto dari database (Base64)
      imageProvider = MemoryImage(base64Decode(_currentImageBase64!));
    } else {
      // 3. Tidak ada foto
      imageProvider = null;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()),
            );
          },
        ),
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check, color: Color(0xFF4894FE)),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              child: Column(
                children: [
                  // --- AVATAR DENGAN TOMBOL EDIT ---
                  GestureDetector(
                    onTap: _pickImage, // Klik avatar untuk ganti foto
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFFD9EAFD),
                          backgroundImage: imageProvider, // Tampilkan gambar
                          child: imageProvider == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color(0xFF4894FE),
                                )
                              : null,
                        ),
                        // Ikon Kamera Kecil (Hanya muncul saat mode edit)
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4894FE),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    nameController.text.isEmpty ? "User" : nameController.text,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _email,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tombol Edit/Simpan
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_isEditing) {
                          _saveProfile();
                        } else {
                          setState(() => _isEditing = true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isEditing
                            ? const Color(0xFF4894FE)
                            : const Color(0xFFEEF6FF),
                        foregroundColor: _isEditing
                            ? Colors.white
                            : const Color(0xFF4894FE),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _isEditing ? "Simpan Perubahan" : "Edit Profil",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Form Fields
                  labeledField(
                    label: "Nama",
                    controller: nameController,
                    isReadOnly: !_isEditing,
                  ),
                  labeledField(
                    label: "Tanggal lahir",
                    controller: birthController,
                    isReadOnly: true,
                    onTap: _selectDate,
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                    ),
                  ),

                  // Gender Dropdown
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Jenis Kelamin",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: _isEditing
                                ? Colors.white
                                : const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _isEditing
                                  ? const Color(0xFFE5E5E5)
                                  : Colors.transparent,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedGender,
                              isExpanded: true,
                              hint: const Text("Pilih jenis kelamin"),
                              items: _genderOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: _isEditing
                                  ? (newValue) => setState(
                                      () => _selectedGender = newValue,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  labeledField(
                    label: "Telepon",
                    controller: phoneController,
                    isReadOnly: !_isEditing,
                  ),
                ],
              ),
            ),
    );
  }
}
