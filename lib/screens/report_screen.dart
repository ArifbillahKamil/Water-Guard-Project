import 'dart:io';
import 'dart:convert'; // Untuk Base64
import 'dart:typed_data'; // Untuk Bytes

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import Auth untuk UID
import 'package:shared_preferences/shared_preferences.dart'; // IMPORT PENTING

import '../widgets/double_wave_header.dart';
import '../screens/dashboard_screen.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  String? _selectedType;
  bool _isLoading = false; // Variabel Loading
  Position? _currentPosition;

  final List<String> _problemTypes = [
    'Pencemaran Air',
    'Tumpahan Minyak',
    'Sampah Menumpuk',
    'Pipa Bocor',
    'Lainnya',
  ];

  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _koordinatController = TextEditingController();

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _koordinatController.dispose();
    super.dispose();
  }

  // --- FUNGSI PILIH GAMBAR (DENGAN CEK PRIVASI) ---
  Future<void> _pickImage() async {
    // 1. CEK IZIN PRIVASI DARI HP
    final prefs = await SharedPreferences.getInstance();
    // Default true jika belum diset
    bool izinData = prefs.getBool('privacy_data') ?? true;

    if (!izinData) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akses Galeri dimatikan di menu Privasi.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return; // Stop di sini, jangan buka galeri
    }

    // 2. Jika boleh, lanjut buka galeri
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 30,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } on PlatformException catch (e) {
      debugPrint('PlatformException _pickImage: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal akses galeri: ${e.message}')),
        );
      }
    } catch (e) {
      debugPrint('Error _pickImage: $e');
    }
  }

  // --- FUNGSI AMBIL LOKASI (DENGAN CEK PRIVASI) ---
  Future<void> _shareLocation() async {
    // 1. CEK IZIN PRIVASI DARI HP
    final prefs = await SharedPreferences.getInstance();
    bool izinLokasi = prefs.getBool('privacy_location') ?? true;

    if (!izinLokasi) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akses Lokasi dimatikan di menu Privasi.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return; // Stop di sini, jangan ambil GPS
    }

    // 2. Jika boleh, lanjut ambil GPS
    try {
      // Cek Service GPS
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Layanan lokasi (GPS) mati. Mohon nyalakan.'),
            ),
          );
        }
        return;
      }

      // Cek Izin Android/iOS
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Izin lokasi ditolak.')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Izin lokasi ditolak permanen. Buka settings untuk ubah.',
              ),
              action: SnackBarAction(
                label: 'SETTINGS',
                onPressed: Geolocator.openAppSettings,
              ),
            ),
          );
        }
        return;
      }

      // Ambil Posisi
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final coords =
          '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';

      setState(() {
        _currentPosition = pos;
        _koordinatController.text = coords;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lokasi didapat: $coords')));
      }
    } catch (e) {
      debugPrint('Error Location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mendapatkan lokasi.')),
        );
      }
    }
  }

  // --- FUNGSI KIRIM LAPORAN ---
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon sertakan foto bukti kejadian.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon ambil titik lokasi terlebih dahulu.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi habis. Silakan login ulang.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageBase64;

      if (_image != null) {
        Uint8List imageBytes = await _image!.readAsBytes();
        imageBase64 = base64Encode(imageBytes);
      }

      await FirebaseFirestore.instance.collection('laporan').add({
        'judul': _judulController.text,
        'deskripsi': _deskripsiController.text,
        'jenis_masalah': _selectedType,
        'koordinat': GeoPoint(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        'foto_base64': imageBase64,
        'tanggal_lapor': FieldValue.serverTimestamp(),
        'status': 'Menunggu Konfirmasi',
        'uid_pelapor': user.uid,
        'email_pelapor': user.email,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan Berhasil Terkirim!'),
            backgroundColor: Colors.green,
          ),
        );

        _judulController.clear();
        _deskripsiController.clear();
        _koordinatController.clear();
        setState(() {
          _image = null;
          _selectedType = null;
          _currentPosition = null;
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim: $e'),
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
    const double headerHeight = 160.0;
    const double topOverlap = 48.0;
    final labelStyle = const TextStyle(fontSize: 12);
    final fieldTextStyle = const TextStyle(fontSize: 12);
    final smallGap = 10.0;
    const double extraTopOffset = 100.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      body: Stack(
        children: [
          // Header
          const SizedBox(
            height: headerHeight,
            child: DoubleWaveHeader(height: headerHeight),
          ),

          // Konten Form
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24.0,
                headerHeight - topOverlap + extraTopOffset,
                24.0,
                24.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Judul
                    TextFormField(
                      controller: _judulController,
                      style: fieldTextStyle,
                      decoration: InputDecoration(
                        labelText: 'Judul Laporan',
                        labelStyle: labelStyle,
                        prefixIcon: const Icon(Icons.title_outlined, size: 18),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    SizedBox(height: smallGap),

                    // Deskripsi
                    TextFormField(
                      controller: _deskripsiController,
                      style: fieldTextStyle,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi Masalah',
                        labelStyle: labelStyle,
                        prefixIcon: const Icon(
                          Icons.description_outlined,
                          size: 18,
                        ),
                        alignLabelWithHint: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                      validator: (value) =>
                          value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    SizedBox(height: smallGap),

                    // Jenis Masalah
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Jenis Masalah',
                        labelStyle: labelStyle,
                        prefixIcon: const Icon(
                          Icons.category_outlined,
                          size: 18,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: fieldTextStyle.copyWith(
                        color: Colors.blue.shade700,
                      ),
                      dropdownColor: Colors.white,
                      items: _problemTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(
                                type,
                                style: fieldTextStyle.copyWith(
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedType = value),
                      validator: (value) =>
                          value == null ? 'Pilih jenis masalah' : null,
                    ),
                    SizedBox(height: smallGap),

                    // Upload Foto
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: _image == null
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.upload_file,
                                      size: 28,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      "Unggah Foto",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _image!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: smallGap),

                    // Koordinat
                    TextFormField(
                      controller: _koordinatController,
                      style: fieldTextStyle,
                      decoration: InputDecoration(
                        labelText: 'Koordinat Lokasi',
                        labelStyle: labelStyle,
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.my_location, size: 18),
                              onPressed: _shareLocation,
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 18),
                              onPressed: () {
                                if (_koordinatController.text.isNotEmpty) {
                                  Clipboard.setData(
                                    ClipboardData(
                                      text: _koordinatController.text,
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Tersalin')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),

                    // Tombol Kirim
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitReport,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: const Color(0xFFD9EAFD),
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
                                "Kirim Laporan",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4894FE),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // Tombol Back
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

          // Judul Header
          Positioned(
            top: 180,
            left: 24,
            child: Text(
              "Laporkan Masalah Perairan",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4894FE),
                shadows: const [
                  Shadow(
                    offset: Offset(1, 2),
                    blurRadius: 3,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
