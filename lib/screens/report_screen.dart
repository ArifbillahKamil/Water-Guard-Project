import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/double_wave_header.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  String? _selectedType;

  final List<String> _problemTypes = [
    'Pencemaran Air',
    'Tumpahan Minyak',
    'Sampah Menumpuk',
    'Pipa Bocor',
    'Lainnya',
  ];

  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _koordinatController = TextEditingController(
    text: '-7.372103200850368, 112.75061827576478',
  );

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 160.0;
    const double topOverlap =
        48.0; // seberapa banyak header menutupi area atas form
    final labelStyle = TextStyle(fontSize: 12);
    final fieldTextStyle = TextStyle(fontSize: 12);
    final smallGap = 10.0;

    // ekstra offset untuk menurunkan seluruh form; ubah nilainya jika perlu
    const double extraTopOffset = 100.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      body: Stack(
        children: [
          // Header di belakang dengan tinggi terbatas
          const SizedBox(
            height: headerHeight,
            child: DoubleWaveHeader(height: headerHeight),
          ),

          // Konten form ditempatkan lebih rendah agar tidak tertutup header
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
                    // Judul laporan (lebih kecil)
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
                          value == null || value.isEmpty ? 'Wajib diisi' : null,
                    ),
                    SizedBox(height: smallGap),

                    // Deskripsi (tinggi dikurangi)
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
                          value == null || value.isEmpty ? 'Wajib diisi' : null,
                    ),
                    SizedBox(height: smallGap),

                    // Jenis masalah (font lebih kecil)
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
                      // warna teks yang tampil saat ada selection (ubah di sini)
                      style: fieldTextStyle.copyWith(
                        color: Colors.blue.shade700,
                      ),
                      // warna background dropdown menu
                      dropdownColor: Colors.white,
                      items: _problemTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              // warna teks di daftar pilihan (ubah di sini)
                              child: Text(
                                type,
                                style: fieldTextStyle.copyWith(
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Pilih jenis masalah' : null,
                    ),
                    SizedBox(height: smallGap),

                    // Upload foto (tinggi sedikit dinaikkan agar nyaman)
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

                    // Koordinat (readOnly) dan ukuran teks lebih kecil
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
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),

                    // Tombol kirim (teks lebih kecil)
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Laporan berhasil dikirim!'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                        backgroundColor: const Color(0xFFD9EAFD),
                      ),
                      child: const Text(
                        "Kirim Laporan",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4894FE),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // Tombol back (di atas header)
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Judul header (di atas header)
          Positioned(
            top: 180,
            left: 24,
            child: Text(
              "Laporkan Masalah Perairan",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4894FE),
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
