import 'package:flutter/material.dart';
import '../widgets/double_wave_header.dart';
import '../widgets/bottom_wave_footer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Wave background
          const DoubleWaveHeader(),
          const BottomWaveFooter(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Title
                  const Text(
                    "My Profile",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4894FE),
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 3,
                          offset: Offset(1, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Profile photo
                  const CircleAvatar(
                    radius: 55,
                    backgroundColor: Color(0xFFD9EAFD),
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 14),

                  // Name
                  const Text(
                    "Jonathan",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  // Email
                  const Text(
                    "Jonathan03@gmail.com",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Edit button
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD9EAFD),
                      foregroundColor: const Color(0xFF4894FE),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 36,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Profile fields
                  buildProfileField("Nama", "Jonathan"),
                  buildProfileField("Tanggal Lahir", "05 Mei 2002"),
                  buildProfileField("Jenis Kelamin", "Laki - Laki"),
                  buildProfileField("Telepon", "0849-1837-1283"),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Widget reusable untuk field profil (pakai Card + ListTile)
  Widget buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: Colors.white, // 👉 background putih
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(
            color: Color(0xFF4894FE), // border biru
            width: 1,
          ),
        ),
        elevation: 2,
        child: ListTile(
          dense: true,
          title: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ),
      ),
    );
  }
}
