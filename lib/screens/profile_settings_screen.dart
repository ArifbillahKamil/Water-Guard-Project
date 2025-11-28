import 'dart:convert'; // Untuk decode Base64
import 'dart:typed_data'; // Untuk Uint8List

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_application_1/screens/bahasa_screen.dart';
import 'package:flutter_application_1/screens/dashboard_screen.dart';
import 'package:flutter_application_1/screens/datapenyimpanan_screen.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import 'package:flutter_application_1/screens/notification_screen.dart';
import 'package:flutter_application_1/screens/bantuan_screen.dart';
import 'package:flutter_application_1/screens/privasi_page.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  String _userName = "Pengguna";
  String _userEmail = "...";
  String? _imageBase64; // Variabel Foto

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? "";
      });

      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _userName = data['username'] ?? "Pengguna";
            _imageBase64 = data['profile_image_base64']; // Ambil foto
          });
        }
      } catch (e) {
        debugPrint("Gagal load: $e");
      }
    }
  }

  void _logout() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Keluar Akun"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Logic tampilan gambar avatar
    ImageProvider? avatarImage;
    if (_imageBase64 != null && _imageBase64!.isNotEmpty) {
      avatarImage = MemoryImage(base64Decode(_imageBase64!));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.black54,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const Dashboard()),
                    );
                  },
                ),

                // CARD PROFILE
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFFD9EAFD),
                        backgroundImage: avatarImage, // Gambar base64
                        child: avatarImage == null
                            ? const Icon(
                                Icons.person,
                                size: 30,
                                color: Color(0xFF4894FE),
                              )
                            : null,
                      ),
                      title: Text(
                        _userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(_userEmail),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: ListView(
                    children: [
                      _SettingsItem(
                        icon: Icons.person_add_alt,
                        title: "Akun",
                        subtitle: "Edit profile, email, data diri",
                        onTap: () {
                          // Gunakan push biasa agar saat kembali, initstate jalan lagi
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                      ),
                      // ... (Item lainnya sama seperti sebelumnya) ...
                      _SettingsItem(
                        icon: Icons.lock_outline,
                        title: "Privasi",
                        subtitle: "Privasi data diri kamu",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivasiPage(),
                          ),
                        ),
                      ),
                      _SettingsItem(
                        icon: Icons.notifications_none,
                        title: "Notifikasi",
                        subtitle: "Pesan, laporan, notifikasi",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationPage(),
                          ),
                        ),
                      ),
                      _SettingsItem(
                        icon: Icons.cloud_download_outlined,
                        title: "Data dan penyimpanan",
                        subtitle: "Penggunaan internet, penyimpanan",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DataStorageScreen(),
                          ),
                        ),
                      ),
                      _SettingsItem(
                        icon: Icons.language,
                        title: "Bahasa aplikasi",
                        subtitle: "Bahasa Indonesia",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LanguageSettingsScreen(),
                          ),
                        ),
                      ),
                      _SettingsItem(
                        icon: Icons.help_outline,
                        title: "Bantuan",
                        subtitle: "Pusat bantuan, hubungi kami",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BantuanScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _SettingsItem(
                        icon: Icons.logout,
                        title: "Keluar",
                        subtitle: "Keluar dari akun",
                        iconColor: Colors.red,
                        textColor: Colors.red,
                        onTap: _logout,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.transparent,
            child: iconColor != null
                ? Icon(icon, size: 26, color: iconColor)
                : ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [Color(0xFF4ADEDE), Color(0xFF4894FE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: Icon(icon, size: 26, color: Colors.white),
                  ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor ?? Colors.black,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: Colors.black54),
          ),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
