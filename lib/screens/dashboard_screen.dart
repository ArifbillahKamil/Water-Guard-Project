import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER DENGAN GAMBAR =====
            Container(
              width: double.infinity,
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4894FE), Color(0xFFB3FEB5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Stack(
                children: [
                  // Gambar di kanan bawah
                  Positioned(
                    right: 10,
                    bottom: 0,
                    child: Image.asset(
                      'assets/hero_worker.png',
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Teks di kiri atas
                  Positioned(
                    left: 16,
                    top: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi, Jonathan!",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Laporkan\nmasalah perairanmu",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Kotak pencarian
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                              )
                            ],
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.search, color: Colors.grey),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: "Search",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== TITIK KOORDINAT =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Titik koordinat anda saat ini",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_pin, color: Colors.black54),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "-7.372103200850368, 112.75061827576478",
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                      ),
                      const Icon(Icons.copy, size: 16, color: Colors.black45),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== 3 MENU UTAMA =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _mainButton(FontAwesomeIcons.fileCircleExclamation, "Laporkan"),
                  _mainButton(FontAwesomeIcons.userPlus, "Mendaftar\nsukarelawan"),
                  _mainButton(FontAwesomeIcons.mapLocationDot, "Lokasi\nbermasalah"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ===== LAPORAN =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Laporan di daerahmu saat ini",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ===== LIST LAPORAN =====
            _reportCard(
              color: Colors.blue,
              icon: FontAwesomeIcons.userShield,
              title: "Sedang ditangani",
              coord: "-7.372071280403217, 112.75091130708668 · 1.2 KM",
            ),
            _reportCard(
              color: Colors.green,
              icon: FontAwesomeIcons.userCheck,
              title: "Sudah ditangani",
              coord: "-7.373071655332484, 112.74897132208254 · 10 KM",
            ),
            _reportCard(
              color: Colors.red,
              icon: FontAwesomeIcons.userSlash, // Ganti userTimes -> userSlash
              title: "Belum terlaksana",
              coord: "-7.373748789247933, 112.74889545757858 · 2.1 KM",
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ====== WIDGET TOMBOL MENU UTAMA ======
  Widget _mainButton(IconData icon, String text) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.black87, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.black87,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ====== WIDGET KARTU LAPORAN ======
  Widget _reportCard({
    required Color color,
    required IconData icon,
    required String title,
    required String coord,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coord,
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
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
