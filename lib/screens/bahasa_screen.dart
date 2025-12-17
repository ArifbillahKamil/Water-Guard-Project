import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // Ambil kode bahasa yang sedang aktif (misal 'id' atau 'en')
    String currentLocaleCode = context.locale.languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black54),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "title_language".tr(), // 2. Gunakan .tr() untuk menerjemahkan
            style: const TextStyle(
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
              "choose_language".tr(), // Gunakan key dari JSON
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),

            // Opsi Indonesia
            _buildLanguageOption(
              context,
              'Indonesia',
              'ID',
              const Locale('id'),
              currentLocaleCode == 'id', // Cek apakah ini bahasa aktif
            ),

            _buildDivider(),

            // Opsi Inggris
            _buildLanguageOption(
              context,
              'English (US)',
              'EN',
              const Locale('en'),
              currentLocaleCode == 'en',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String languageName,
    String codeDisplay,
    Locale localeTarget,
    bool isActive,
  ) {
    return GestureDetector(
      onTap: () async {
        // 3. FUNGSI AJAIB PENGUBAH BAHASA
        await context.setLocale(localeTarget);

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("msg_changed".tr())));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.blue.withOpacity(0.05)
              : Colors.white, // Highlight jika aktif
          borderRadius: BorderRadius.circular(12),
          border: isActive ? Border.all(color: const Color(0xFF4894FE)) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  codeDisplay,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF00796B),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                languageName,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF111827),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Radio button otomatis mengikuti status isActive
            Radio<bool>(
              value: true,
              groupValue: isActive, // Jika isActive true, radio nyala
              onChanged: (val) {
                context.setLocale(localeTarget);
              },
              activeColor: const Color(0xFF4894FE),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const SizedBox(height: 10);
  }
}
