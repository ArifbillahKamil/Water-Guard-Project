import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter_application_1/screens/Worker_Sign_up.dart';
import 'package:flutter_application_1/screens/lokasi_bermasalah.dart';
import 'package:flutter_application_1/screens/notification_screen.dart';
import 'package:flutter_application_1/screens/profile_settings_screen.dart';
import 'package:flutter_application_1/screens/report_screen.dart';
import 'package:flutter_application_1/screens/admin_reportlist_screen.dart';
import 'package:flutter_application_1/screens/admin_volunteer_list_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String _locationMessage = "Mencari lokasi...";
  String _userName = "User";
  String _userRole = "user";

  @override
  void initState() {
    super.initState();
    _getUserData();
    _getCurrentLocation();
  }

  Future<void> _getUserData() async {
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
            _userRole = userDoc['role'] ?? "user";
          });
        }
      } catch (e) {
        debugPrint("Gagal data user: $e");
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLocationAllowed = prefs.getBool('privacy_location') ?? true;

    if (!isLocationAllowed) {
      if (mounted) setState(() => _locationMessage = "Lokasi Disembunyikan");
      return;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _locationMessage = "GPS Mati");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
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

    String menuTitleKey = _userRole == 'volunteer'
        ? 'btn_volunteer_panel'
        : 'btn_admin_panel';

    String menuDescKey = _userRole == 'volunteer'
        ? 'desc_volunteer_panel'
        : 'desc_admin_panel';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _DashboardHeader(userName: _userName),

              const SizedBox(height: 40),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: _CoordinateRow(coordinate: _locationMessage),
              ),

              const SizedBox(height: 20),

              // ==========================================
              // MENU KHUSUS ADMIN / RELAWAN (CARD BESAR)
              // ==========================================
              if (_userRole == 'admin' || _userRole == 'volunteer')
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: GestureDetector(
                    onTap: () {
                      // 2. LOGIKA BARU UNTUK ADMIN
                      if (_userRole == 'admin') {
                        // Tampilkan Menu Pilihan
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) {
                            return Wrap(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.report_problem,
                                    color: Colors.blue,
                                  ),
                                  title: Text(
                                    'Kelola Laporan Warga',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Lihat dan update status laporan',
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context); // Tutup menu
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AdminReportListScreen(
                                          userRole: _userRole,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.people,
                                    color: Colors.green,
                                  ),
                                  title: Text(
                                    'Kelola Pendaftaran Relawan',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Verifikasi pendaftar baru',
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context); // Tutup menu
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AdminVolunteerListScreen(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 30),
                              ],
                            );
                          },
                        );
                      } else {
                        // Jika Relawan Biasa, langsung ke Laporan
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminReportListScreen(userRole: _userRole),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  menuTitleKey.tr(),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  menuDescKey.tr(),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ==========================================
              // MENU UTAMA (Lapor, Relawan, Peta)
              // ==========================================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RoundMenu(
                      icon: FontAwesomeIcons.fileCircleExclamation,
                      label: 'menu_report'.tr(),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportFormScreen(),
                        ),
                      ),
                    ),
                    _RoundMenu(
                      icon: FontAwesomeIcons.userPlus,
                      label: 'menu_volunteer'.tr(),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WorkerSignUpScreen(),
                        ),
                      ),
                    ),
                    _RoundMenu(
                      icon: FontAwesomeIcons.mapLocationDot,
                      label: 'menu_map'.tr(),
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        bool isLocationAllowed =
                            prefs.getBool('privacy_location') ?? true;
                        if (!isLocationAllowed) {
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
                          return;
                        }
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

// HEADER
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
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationPage()),
                ),
                icon: const Icon(Icons.notifications_none, color: Colors.white),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileSettingsScreen(),
                  ),
                ),
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
                'dash_hi'.tr(),
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
                'dash_subtitle'.tr(),
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
                        hintText: 'search_hint'.tr(),
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

// KOORDINAT
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

// MENU BUTTON
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

// LIST LAPORAN
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
            'recent_reports'.tr(),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('laporan')
                .orderBy('tanggal_lapor', descending: true)
                .limit(3)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              if (snapshot.hasError) return const Text("Gagal memuat data");
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Belum ada laporan."),
                );
              final docs = snapshot.data!.docs;
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  String coordStr = '-';
                  if (data['koordinat'] is GeoPoint) {
                    GeoPoint gp = data['koordinat'];
                    coordStr =
                        "${gp.latitude.toStringAsFixed(4)}, ${gp.longitude.toStringAsFixed(4)}";
                  } else if (data['koordinat'] != null) {
                    coordStr = data['koordinat'].toString();
                  }
                  String status = data['status'] ?? 'Menunggu';
                  Color statusColor = Colors.orange;
                  Color bgColor = Colors.orange.shade50;
                  if (status == 'Selesai') {
                    statusColor = const Color(0xFF21B356);
                    bgColor = const Color(0xFFDFF7E6);
                  } else if (status == 'Diproses' ||
                      status == 'Sedang Proses') {
                    statusColor = const Color(0xFF2E7DF6);
                    bgColor = const Color(0xFFBEE3FF);
                  } else if (status == 'Ditolak') {
                    statusColor = Colors.red;
                    bgColor = Colors.red.shade50;
                  }
                  String judul = data['judul'] ?? 'Laporan';
                  return _ReportRow(
                    color: bgColor,
                    statusColor: statusColor,
                    coord: coordStr,
                    statusLabel: status,
                    distance: judul,
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
