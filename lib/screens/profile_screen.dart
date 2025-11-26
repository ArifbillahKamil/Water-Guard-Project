import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/profile_settings_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController(
    text: "Jonathan",
  );
  final TextEditingController birthController = TextEditingController(
    text: "05 Mei 2002",
  );
  final TextEditingController genderController = TextEditingController(
    text: "Laki - Laki",
  );
  final TextEditingController phoneController = TextEditingController(
    text: "0849-1837-1283",
  );
  final String email = "Jonathan03@gmail.com";

  @override
  void dispose() {
    nameController.dispose();
    birthController.dispose();
    genderController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  InputDecoration fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF4894FE), width: 1.6),
      ),
    );
  }

  Widget labeledField(String label, TextEditingController controller) {
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
            decoration: fieldDecoration(),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),

      // ========= APPBAR BARU (selaras LanguageSettingsScreen) =========
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
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
            "My Profile",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            CircleAvatar(
              radius: 48,
              backgroundColor: const Color(0xFFD9EAFD),
              backgroundImage: const NetworkImage(
                'https://i.pravatar.cc/300?img=65',
              ),
            ),
            const SizedBox(height: 12),

            Text(
              nameController.text,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black54,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 14),

            // Tombol edit profil
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEEF6FF),
                foregroundColor: const Color(0xFF4894FE),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 22,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Edit profile",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 22),

            // ====== INPUT FIELDS ======
            labeledField("Nama", nameController),
            labeledField("Tanggal lahir", birthController),
            labeledField("Jenis kelamin", genderController),
            labeledField("Telepon", phoneController),
          ],
        ),
      ),
    );
  }
}
