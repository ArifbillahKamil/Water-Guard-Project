import 'package:flutter/material.dart';
import '../widgets/double_wave_header.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      body: Column(
        children: [
          // ===== HEADER KONSISTEN TANPA JAM =====
          Stack(
            children: [
              const DoubleWaveHeader(height: 170),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Notifikasi",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(1, 2),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ===== KONTEN NOTIFIKASI =====
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              children: const [
                NotificationCard(
                  title: "⚠️ Peringatan Akun",
                  titleColor: Colors.red,
                  subtitleBold: "Verifikasi alamat email anda",
                  message:
                      "Segera verifikasi alamat email anda demi keamanan dan kenyamanan anda dalam menggunakan aplikasi ini.",
                  icon: Icons.email_rounded,
                  iconColor: Colors.purpleAccent,
                  bgColor: Color(0xFFFDE8E8),
                ),
                SizedBox(height: 16),
                NotificationCard(
                  title: "Laporanmu sedang dikerjakan",
                  titleColor: Color(0xFF2E7DF6),
                  subtitleBold: "",
                  message:
                      "Laporanmu mengenai permasalahan banjir karena perairan tersumbat, saat ini sedang ditangani.",
                  icon: Icons.settings,
                  iconColor: Colors.blueAccent,
                  bgColor: Color(0xFFE8F0FE),
                ),
                SizedBox(height: 16),
                NotificationCard(
                  title: "Terimakasih Relawan",
                  titleColor: Color(0xFF21B356),
                  subtitleBold: "",
                  message:
                      "Kamu sudah menyelesaikan laporan warga setempat dengan baik, klaim reward kamu sekarang.",
                  icon: Icons.card_giftcard,
                  iconColor: Colors.green,
                  bgColor: Color(0xFFE8FEE8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===== WIDGET CARD NOTIFIKASI =====
class NotificationCard extends StatelessWidget {
  final String title;
  final Color titleColor;
  final String subtitleBold;
  final String message;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const NotificationCard({
    super.key,
    required this.title,
    required this.titleColor,
    required this.subtitleBold,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 28, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                    height: 1.2,
                  ),
                ),
                if (subtitleBold.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitleBold,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
