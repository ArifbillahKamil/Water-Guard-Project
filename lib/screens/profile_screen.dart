import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. IMPORT INI

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

  File? _newImageFile;
  String? _currentImageBase64;

  bool _isEditing = false;
  bool _isLoading = false;

  // LOGIKA GENDER: Simpan dalam key bahasa agar mudah di-map
  final List<String> _genderKeys = ['prof_gender_male', 'prof_gender_female'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

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

            // Kita simpan value asli (ID/EN) ke state
            _selectedGender = data['gender'];
            _currentImageBase64 = data['profile_image_base64'];
          });
        }
      } catch (e) {
        debugPrint("Gagal load profile: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    if (!_isEditing) return;
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 20,
      );
      if (pickedFile != null) {
        setState(() => _newImageFile = File(pickedFile.path));
      }
    } catch (e) {
      debugPrint("Gagal ambil foto: $e");
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        Map<String, dynamic> dataToUpdate = {
          'username': nameController.text,
          'phone': phoneController.text,
          'tgl_lahir': birthController.text,
          'gender': _selectedGender, // Menyimpan teks yang sedang dipilih
          'updated_at': FieldValue.serverTimestamp(),
        };

        if (_newImageFile != null) {
          Uint8List imageBytes = await _newImageFile!.readAsBytes();
          String base64String = base64Encode(imageBytes);
          dataToUpdate['profile_image_base64'] = base64String;
          _currentImageBase64 = base64String;
          _newImageFile = null;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(dataToUpdate, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('msg_prof_saved'.tr()),
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
    ImageProvider? imageProvider;
    if (_newImageFile != null) {
      imageProvider = FileImage(_newImageFile!);
    } else if (_currentImageBase64 != null && _currentImageBase64!.isNotEmpty) {
      imageProvider = MemoryImage(base64Decode(_currentImageBase64!));
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
        title: Text(
          "prof_title".tr(),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
          ),
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
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFFD9EAFD),
                          backgroundImage: imageProvider,
                          child: imageProvider == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color(0xFF4894FE),
                                )
                              : null,
                        ),
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
                        _isEditing
                            ? "prof_save_btn".tr()
                            : "prof_edit_btn".tr(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  labeledField(
                    label: "prof_label_name".tr(),
                    controller: nameController,
                    isReadOnly: !_isEditing,
                  ),
                  labeledField(
                    label: "prof_label_birth".tr(),
                    controller: birthController,
                    isReadOnly: true,
                    onTap: _selectDate,
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                    ),
                  ),
                  // Dropdown Gender
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "prof_label_gender".tr(),
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
                              hint: Text("prof_gender_hint".tr()),
                              // Logic: Bandingkan value dengan terjemahan key
                              items: _genderKeys.map((String key) {
                                return DropdownMenuItem<String>(
                                  value: key.tr(), // Simpan hasil translate
                                  child: Text(key.tr()),
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
                    label: "prof_label_phone".tr(),
                    controller: phoneController,
                    isReadOnly: !_isEditing,
                  ),
                ],
              ),
            ),
    );
  }
}
