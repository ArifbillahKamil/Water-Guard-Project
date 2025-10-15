import 'package:flutter/material.dart';
import '../widgets/double_wave_header.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Column(
        children: [
          // header with gradient (kept consistent via DoubleWaveHeader)
          SizedBox(
            height:
                180, // beri tinggi tetap agar Positioned berada di area yang aman
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const DoubleWaveHeader(height: 140),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.maybePop(context),
                        ),
                      ],
                    ),
                  ),
                ),

                // main page title positioned to sit under the wave
                Positioned(
                  left: 24,
                  top: 150, // sesuaikan relatif ke tinggi SizedBox
                  child: const Text(
                    'Notifikasi',
                    style: TextStyle(
                      color: Color(0xFF3C8CE7),
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      shadows: [
                        Shadow(
                          color: Color(0x553C8CE7),
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 14,
          ), // cukup sedikit jarak karena SizedBox di atas sudah memberikan ruang

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              children: const [
                SizedBox(height: 6),
                CustomNotificationCard(
                  title: 'Peringatan akun',
                  titleColor: Color(0xFFE35247),
                  subtitleBold: 'verifikasi alamat email anda',
                  message:
                      'Segera verifikasi alamat email anda demi keamanan dan kenyamanan anda dalam menggunakan aplikasi ini',
                  icon: Icons.email_rounded,
                  iconColor: Color(0xFF8B5CF6),
                ),
                SizedBox(height: 14),
                CustomNotificationCard(
                  title: 'Laporanmu sedang dikerjakan',
                  titleColor: Color(0xFF111827),
                  subtitleBold: '',
                  message:
                      'laporanmu mengenai permasalahan banjir karena perairan tersumbat, saat ini sedang ditangani.',
                  icon: Icons.settings,
                  iconColor: Color(0xFF2E7DF6),
                ),
                SizedBox(height: 14),
                CustomNotificationCard(
                  title: 'Terimakasih Relawan',
                  titleColor: Color(0xFF111827),
                  subtitleBold: '',
                  message:
                      'kamu sudah menyelesaikan laporan warga setempat dengan baik, klaim reward kamu sekarang.',
                  icon: Icons.card_giftcard,
                  iconColor: Color(0xFF21B356),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomNotificationCard extends StatelessWidget {
  final String title;
  final Color titleColor;
  final String subtitleBold;
  final String message;
  final IconData icon;
  final Color iconColor;

  const CustomNotificationCard({
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
      height: 140, // dinaikkan supaya konten panjang tidak overflow
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // isi diratakan ke atas
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment
                  .start, // jangan center, supaya teks tidak terdorong bawah
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                if (subtitleBold.isNotEmpty) const SizedBox(height: 6),
                if (subtitleBold.isNotEmpty)
                  Text(
                    subtitleBold,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  maxLines: 3, // batasi jumlah baris agar tidak overflow
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: iconColor.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
