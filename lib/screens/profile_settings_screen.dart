import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/bottom_wave_footer.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // ===== Wave di bawah =====
            const BottomWaveFooter(),

            // ===== Konten utama =====
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tombol back
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),

                // Profile Card
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
                      leading: const CircleAvatar(
                        radius: 28,
                        backgroundImage: AssetImage("assets/images/avatar.jpg"),
                      ),
                      title: const Text(
                        "Jonathan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text("Jonathan03@gmail.com"),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Menu list
                Expanded(
                  child: ListView(
                    children: const [
                      _SettingsItem(
                        icon: Icons.person_add_alt,
                        title: "Akun",
                        subtitle: "Edit profile, email, data diri",
                      ),
                      _SettingsItem(
                        icon: Icons.lock_outline,
                        title: "Privasi",
                        subtitle: "Privasi data diri kamu",
                      ),
                      _SettingsItem(
                        icon: Icons.notifications_none,
                        title: "Notifikasi",
                        subtitle: "Pesan, laporan, notifikasi",
                      ),
                      _SettingsItem(
                        icon: Icons.cloud_download_outlined,
                        title: "Data dan penyimpanan",
                        subtitle: "Penggunaan internet, penyimpanan",
                      ),
                      _SettingsItem(
                        icon: Icons.language,
                        title: "Bahasa aplikasi",
                        subtitle: "Bahasa Indonesia",
                      ),
                      _SettingsItem(
                        icon: Icons.help_outline,
                        title: "Help",
                        subtitle: "Help centre, contact us, privacy policy",
                      ),
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

// ===== Custom Widget untuk List Item =====
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.transparent,
            child: ShaderMask(
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: Colors.black54),
          ),
          onTap: () {
            // TODO: navigasi ke halaman terkait
          },
        ),
        const Divider(height: 1),
      ],
    );
  }
}
