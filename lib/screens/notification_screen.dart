import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      body: Column(
        children: [
          // ===== HEADER DENGAN WAVE =====
          Stack(
            children: [
              ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4da0ff), Color(0xFF9ef5c0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Stack(
                    children: [
                      // Tombol Back
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      // Status Bar Icons
                      Align(
                        alignment: Alignment.topRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.alarm, color: Colors.white),
                            SizedBox(width: 8),
                            Icon(Icons.bluetooth, color: Colors.white),
                            SizedBox(width: 8),
                            Icon(Icons.wifi, color: Colors.white),
                            SizedBox(width: 8),
                            Icon(Icons.signal_cellular_alt, color: Colors.white),
                          ],
                        ),
                      ),
                      // Jam
                      const Positioned(
                        left: 60,
                        top: 20,
                        child: Text(
                          "5:13 PM",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ===== JUDUL NOTIFIKASI =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Notifikasi",
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4da0ff),
                letterSpacing: 0.5,
                shadows: const [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(1, 2),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ===== KONTEN NOTIFIKASI =====
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: const [
                NotificationCard(
                  title: "⚠️ peringatan akun",
                  titleColor: Colors.red,
                  subtitleBold: "verifikasi alamat email anda",
                  message:
                      "Segera verifikasi alamat email anda demi keamanan dan kenyamanan anda dalam menggunakan aplikasi ini",
                  icon: Icons.email_rounded,
                  iconColor: Colors.purpleAccent,
                ),
                SizedBox(height: 20),
                NotificationCard(
                  title: "Laporanmu sedang dikerjakan",
                  titleColor: Colors.black,
                  subtitleBold: "",
                  message:
                      "laporanmu mengenai permasalahan banjir karena perairan tersumbat, saat ini sedang ditangani.",
                  icon: Icons.settings,
                  iconColor: Colors.blueAccent,
                ),
                SizedBox(height: 20),
                NotificationCard(
                  title: "Terimakasih Relawan",
                  titleColor: Colors.black,
                  subtitleBold: "",
                  message:
                      "kamu sudah menyelesaikan laporan warga setempat dengan baik, klaim reward kamu sekarang.",
                  icon: Icons.card_giftcard,
                  iconColor: Colors.green,
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

  const NotificationCard({
    super.key,
    required this.title,
    required this.titleColor,
    required this.subtitleBold,
    required this.message,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(2, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul Kecil
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                // Subjudul (bold)
                if (subtitleBold.isNotEmpty)
                  Text(
                    subtitleBold,
                    style: GoogleFonts.poppins(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      height: 1.3,
                    ),
                  ),
                if (subtitleBold.isNotEmpty) const SizedBox(height: 4),
                // Isi pesan
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, size: 38, color: iconColor),
        ],
      ),
    );
  }
}

// ===== CLIPPER WAVE =====
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, size.height - 40);

    final firstControlPoint = Offset(size.width / 4, size.height);
    final firstEndPoint = Offset(size.width / 2, size.height - 40);
    final secondControlPoint = Offset(3 * size.width / 4, size.height - 80);
    final secondEndPoint = Offset(size.width, size.height - 40);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
