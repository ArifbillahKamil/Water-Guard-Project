// lib/screens/language_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import 'package:flutter_application_1/screens/profile_settings_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String? _selectedLanguage = 'Indonesia'; // Bahasa default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      // ===== APPBAR BARU =====
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black54),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileSettingsScreen(),
                  ),
                );
              }
            },
          ),
          title: const Text(
            "Bahasa",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Bahasa Aplikasi',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            _buildLanguageOption(context, 'Indonesia', 'ID'),
            _buildDivider(),
            _buildLanguageOption(context, 'English (US)', 'EN'),
            _buildDivider(),
            _buildLanguageOption(
              context,
              '日本語 (Japanese)', // Contoh bahasa lain
              'JP',
            ),
            _buildDivider(),
            _buildLanguageOption(
              context,
              '中文 (Chinese)', // Contoh bahasa lain
              'CN',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String language,
    String code,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = language;
          // Di sini Anda bisa menambahkan logika untuk menyimpan pilihan bahasa
          // misal pakai SharedPreferences atau Provider/Bloc
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Bahasa diubah ke $language')));
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        margin: const EdgeInsets.only(bottom: 8), // Margin antar opsi
        child: Row(
          children: [
            // Icon bendera atau representasi bahasa
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7FA), // Warna background icon
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  code, // Kode negara atau inisial bahasa
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF00796B), // Warna teks icon
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                language,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF111827),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Radio<String>(
              value: language,
              groupValue: _selectedLanguage,
              onChanged: (String? value) {
                setState(() {
                  _selectedLanguage = value;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Bahasa diubah ke $value')),
                  );
                });
              },
              activeColor: const Color(
                0xFF4894FE,
              ), // Warna radio button saat aktif
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const SizedBox(height: 10); // Spasi antar opsi
  }
}
