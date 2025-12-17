import 'dart:convert'; // Untuk decode Base64
import 'dart:typed_data'; // Untuk Uint8List

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. WAJIB IMPORT INI

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
        title: Text("logout_title".tr()), // Translate Judul Dialog
        content: Text("logout_msg".tr()), // Translate Isi Dialog
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("btn_cancel".tr()), // Translate Batal
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "btn_confirm_logout".tr(), // Translate Keluar
              style: const TextStyle(color: Colors.red),
            ),
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
    // 1. LOGIK UNTUK MENAMPILKAN NAMA BAHASA SAAT INI
    // Cek kode bahasa (id / en) lalu tentukan teks yang tampil
    String currentLangName = context.locale.languageCode == 'en'
        ? 'English (US)'
        : 'Bahasa Indonesia';

    // Logic tampilan gambar avatar
    ImageProvider? avatarImage;
    if (_imageBase64 != null && _imageBase64!.isNotEmpty) {
      try {
        avatarImage = MemoryImage(base64Decode(_imageBase64!));
      } catch (e) {
        debugPrint("Error decoding image: $e");
      }
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
                      // MENU AKUN
                      _SettingsItem(
                        icon: Icons.person_add_alt,
                        title: "set_account".tr(), // "Akun"
                        subtitle: "set_account_desc".tr(),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                      ),

                      // MENU PRIVASI
                      _SettingsItem(
                        icon: Icons.lock_outline,
                        title: "set_privacy".tr(), // "Privasi"
                        subtitle: "set_privacy_desc".tr(),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivasiPage(),
                          ),
                        ),
                      ),

                      // MENU NOTIFIKASI
                      _SettingsItem(
                        icon: Icons.notifications_none,
                        title: "set_notif".tr(), // "Notifikasi"
                        subtitle: "set_notif_desc".tr(),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationPage(),
                          ),
                        ),
                      ),

                      // MENU DATA & PENYIMPANAN
                      _SettingsItem(
                        icon: Icons.cloud_download_outlined,
                        title: "set_storage".tr(), // "Data dan penyimpanan"
                        subtitle: "set_storage_desc".tr(),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DataStorageScreen(),
                          ),
                        ),
                      ),

                      // MENU BAHASA (Subtitle Dinamis)
                      _SettingsItem(
                        icon: Icons.language,
                        title: "set_language".tr(), // "Bahasa aplikasi"
                        subtitle:
                            currentLangName, // <--- INI BERUBAH SESUAI PILIHAN
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LanguageSettingsScreen(),
                          ),
                        ),
                      ),

                      // MENU BANTUAN
                      _SettingsItem(
                        icon: Icons.help_outline,
                        title: "set_help".tr(), // "Bantuan"
                        subtitle: "set_help_desc".tr(),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BantuanScreen(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // MENU KELUAR
                      _SettingsItem(
                        icon: Icons.logout,
                        title: "set_logout".tr(), // "Keluar"
                        subtitle: "set_logout_desc".tr(),
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
