import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart'; // Import Geolocator
import 'package:firebase_auth/firebase_auth.dart'; // Import Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. WAJIB IMPORT INI

import 'package:flutter_application_1/screens/Worker_Sign_up.dart';
import 'package:flutter_application_1/screens/lokasi_bermasalah.dart';
import 'package:flutter_application_1/screens/notification_screen.dart';
import 'package:flutter_application_1/screens/profile_settings_screen.dart';
import 'package:flutter_application_1/screens/report_screen.dart';

// =============================
// DASHBOARD SCREEN (STATEFUL)
// =============================
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String _locationMessage = "Mencari lokasi...";
  String _userName = "User";

  @override
  void initState() {
    super.initState();
    _getUserName();
    _getCurrentLocation(); // Cek lokasi saat awal buka
  }

  // --- AMBIL NAMA USER ---
  Future<void> _getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userName = userDoc['username'] ?? "User";
          });
        }
      } catch (e) {
        debugPrint("Gagal mengambil nama user: $e");
      }
    }
  }

  // --- 2. FUNGSI AMBIL LOKASI (DENGAN CEK PRIVASI) ---
  Future<void> _getCurrentLocation() async {
    // A. CEK SAKLAR PRIVASI DULU
    final prefs = await SharedPreferences.getInstance();
    // Default true jika belum pernah diset
    bool isLocationAllowed = prefs.getBool('privacy_location') ?? true;

    if (!isLocationAllowed) {
      if (mounted) {
        setState(() {
          _locationMessage = "Lokasi Disembunyikan"; // Ubah teks jika dimatikan
        });
      }
      return; // Stop, jangan akses GPS
    }

    // B. Jika diizinkan, lanjut akses GPS seperti biasa
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _locationMessage = "GPS Mati");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _locationMessage = "Izin Ditolak");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _locationMessage = "Izin Permanen Ditolak");
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _locationMessage =
              "${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}";
        });
      }
    } catch (e) {
      if (mounted) setState(() => _locationMessage = "Gagal memuat");
    }
  }

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
              // HEADER
              _DashboardHeader(userName: _userName),

              const SizedBox(height: 40),

              // KOORDINAT
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: _CoordinateRow(coordinate: _locationMessage),
              ),

              const SizedBox(height: 20),

              // MENU UTAMA
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Menu 1: Lapor (Selalu Buka)
                    _RoundMenu(
                      icon: FontAwesomeIcons.fileCircleExclamation,
                      label: 'Laporkan',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportFormScreen(),
                        ),
                      ),
                    ),

                    // Menu 2: Daftar Relawan (Selalu Buka)
                    _RoundMenu(
                      icon: FontAwesomeIcons.userPlus,
                      label: 'Mendaftar\nSukarelawan',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WorkerSignUpScreen(),
                        ),
                      ),
                    ),

                    // Menu 3: Peta (DIBATASI OLEH PRIVASI)
                    _RoundMenu(
                      icon: FontAwesomeIcons.mapLocationDot,
                      label: 'Lokasi\nBermasalah',
                      onTap: () async {
                        // 3. CEK SAKLAR PRIVASI SEBELUM BUKA PETA
                        final prefs = await SharedPreferences.getInstance();
                        bool isLocationAllowed =
                            prefs.getBool('privacy_location') ?? true;

                        if (!isLocationAllowed) {
                          // Jika dimatikan, munculkan peringatan
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Akses Peta dimatikan di menu Privasi.',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                          return; // JANGAN PINDAH HALAMAN
                        }

                        // Jika hidup, baru pindah
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PetaLaporanScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // LAPORAN DAERAH
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
// HEADER WIDGET
// =============================
class _DashboardHeader extends StatelessWidget {
  final String userName;
  const _DashboardHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: 280,
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
        Positioned(
          top: 38,
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
        Positioned(
          left: 28,
          top: 50,
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
                '$userName!',
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
// COORDINATE WIDGET
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
// MENU BUTTON WIDGET
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
// LIST LAPORAN REAL-TIME (FIRESTORE)
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
            'Laporan Terbaru',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // --- STREAM BUILDER ---
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('laporan')
                .orderBy('tanggal_lapor', descending: true)
                .limit(3)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasError) {
                return const Text("Gagal memuat data");
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Belum ada laporan."),
                );
              }

              final docs = snapshot.data!.docs;

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;

                  // Parse Koordinat
                  String coordStr = '-';
                  if (data['koordinat'] is GeoPoint) {
                    GeoPoint gp = data['koordinat'];
                    coordStr =
                        "${gp.latitude.toStringAsFixed(4)}, ${gp.longitude.toStringAsFixed(4)}";
                  } else if (data['koordinat'] != null) {
                    coordStr = data['koordinat'].toString();
                  }

                  // Parse Status & Warna
                  String status = data['status'] ?? 'Menunggu';
                  Color statusColor = const Color(0xFFE35247); // Merah
                  Color bgColor = const Color(0xFFFEECEB);

                  if (status == 'Selesai') {
                    statusColor = const Color(0xFF21B356); // Hijau
                    bgColor = const Color(0xFFDFF7E6);
                  } else if (status == 'Sedang Proses') {
                    statusColor = const Color(0xFF2E7DF6); // Biru
                    bgColor = const Color(0xFFBEE3FF);
                  }

                  String jenis = data['jenis_masalah'] ?? 'Laporan';

                  return _ReportRow(
                    color: bgColor,
                    statusColor: statusColor,
                    coord: coordStr,
                    statusLabel: status,
                    distance: jenis,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// =============================
// ROW ITEM LAPORAN
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
                        Icons.info_outline,
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
      ],
    );
  }
}
