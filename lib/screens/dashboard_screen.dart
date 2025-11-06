import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/Worker_Sign_up.dart';
import 'package:flutter_application_1/screens/lokasi_bermasalah.dart';
import 'package:flutter_application_1/screens/notification_screen.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import 'package:flutter_application_1/screens/profile_settings_screen.dart';
import 'package:flutter_application_1/screens/report_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

// =============================
// DASHBOARD SCREEN
// =============================
class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final padding = width * 0.05;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // === HEADER ===
              const _DashboardHeader(),

              const SizedBox(height: 40),

              // === KOORDINAT ===
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: const _CoordinateRow(
                  coordinate: '-7.372103200850368, 112.75061827576478',
                ),
              ),

              const SizedBox(height: 20),

              // === MENU UTAMA ===
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _RoundMenu(
                      icon: FontAwesomeIcons.fileCircleExclamation,
                      label: 'Laporkan',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReportFormScreen(),
                          ),
                        );
                      },
                    ),
                    _RoundMenu(
                      icon: FontAwesomeIcons.userPlus,
                      label: 'Mendaftar\nSukarelawan',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WorkerSignUpScreen(),
                          ),
                        );
                      },
                    ),
                    _RoundMenu(
                      icon: FontAwesomeIcons.mapLocationDot,
                      label: 'Lokasi\nBermasalah',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PetaLaporanScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // === LAPORAN DAERAH ===
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: const _ReportList(),
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================
// HEADER
// =============================
class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background Gradient
        Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4894FE), Color(0xFFB3FEB5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),

        // Icon notifikasi & avatar
        Positioned(
          top: 18,
          right: 18,
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationPage()),
                  );
                },
                icon: const Icon(Icons.notifications_none, color: Colors.white),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileSettingsScreen(),
                    ),
                  );
                },
                child: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),

        // Greeting dan teks utama
        Positioned(
          left: 18,
          top: 22,
          right: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi,',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                'Jonathan!',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Laporkan\nmasalah perairanmu',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                ),
              ),
            ],
          ),
        ),

        // Hero image kanan
        Positioned(
          right: 12,
          bottom: 8,
          child: Image.asset(
            'assets/hero_worker.png',
            height: 160,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.person, size: 80, color: Colors.white24),
          ),
        ),

        // Kotak pencarian
        Positioned(
          left: 20,
          right: 20,
          bottom: 14,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(14),
            color: Colors.transparent,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF9AA3B2)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration.collapsed(
                        hintText: 'Search',
                        hintStyle: GoogleFonts.poppins(
                          color: const Color(0xFF9AA3B2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================
// KOORDINAT ROW
// =============================
class _CoordinateRow extends StatelessWidget {
  final String coordinate;
  const _CoordinateRow({required this.coordinate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, color: Color(0xFF1F2937)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            coordinate,
            style: GoogleFonts.poppins(
              color: const Color(0xFF111827),
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: coordinate));
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Koordinat disalin')));
          },
          child: const Icon(Icons.copy, size: 18, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}

// =============================
// MENU BULAT
// =============================
class _RoundMenu extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _RoundMenu({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 86,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Icon(icon, size: 28, color: const Color(0xFF111827)),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================
// DAFTAR LAPORAN
// =============================
class _ReportList extends StatelessWidget {
  const _ReportList();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laporan di daerahmu saat ini',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _ReportRow(
            color: const Color(0xFFBEE3FF),
            statusColor: const Color(0xFF2E7DF6),
            coord: '-7.372071280403217, 112.75091130708668',
            statusLabel: 'Sedang ditangani',
            distance: '1.2 KM',
          ),
          const SizedBox(height: 8),
          _ReportRow(
            color: const Color(0xFFDFF7E6),
            statusColor: const Color(0xFF21B356),
            coord: '-7.373071655332484, 112.74897132208254',
            statusLabel: 'Sudah ditangani',
            distance: '1.0 KM',
          ),
          const SizedBox(height: 8),
          _ReportRow(
            color: const Color(0xFFFEECEB),
            statusColor: const Color(0xFFE35247),
            coord: '-7.373748788247933, 112.74889545775858',
            statusLabel: 'Belum terlaksana',
            distance: '2.1 KM',
          ),
        ],
      ),
    );
  }
}

// =============================
// SATU ROW LAPORAN
// =============================
class _ReportRow extends StatelessWidget {
  final Color color;
  final Color statusColor;
  final String coord;
  final String statusLabel;
  final String distance;

  const _ReportRow({
    required this.color,
    required this.statusColor,
    required this.coord,
    required this.statusLabel,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(Icons.location_on, color: statusColor, size: 22),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                coord,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF0F172A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        distance,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: coord));
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Koordinat disalin')));
          },
          child: const Icon(Icons.copy, size: 18, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }
}

// =============================
// DUMMY PAGE (sementara)
// =============================
class DummyPage extends StatelessWidget {
  final String title;
  const DummyPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title sedang dikembangkan...',
          style: GoogleFonts.poppins(fontSize: 16),
        ),
      ),
    );
  }
}
