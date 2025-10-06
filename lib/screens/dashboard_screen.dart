import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // ==== DATA DUMMY ====
    final reports = <Report>[
      Report(
        coord: '-7.372071280403217, 112.75091130708668',
        statusLabel: 'Sedang di tangani',
        statusKey: ReportStatus.progress,
        distance: '1.2 KM',
      ),
      Report(
        coord: '-7.373071655332484, 112.74897132208254',
        statusLabel: 'Sudah ditangani',
        statusKey: ReportStatus.done,
        distance: '1.0 KM',
      ),
      Report(
        coord: '-7.373748788247933, 112.74889545775858',
        statusLabel: 'Belum terlaksana',
        statusKey: ReportStatus.pending,
        distance: '2.1 KM',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER + GAMBAR ORANG =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7BD5F5), Color(0xFF787FF6)],
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Hi, Jonathan!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10),
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 16,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Laporkan\nmasalah\nperairanmu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: 'Search',
                              border: InputBorder.none,
                              icon: Icon(Icons.search, color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      bottom: -6,
                      child: Image.asset(
                        'assets/hero_worker.png', // gambar orang di header
                        width: 130,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ===== KOORDINAT =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Titik koordinat anda saat ini',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.black87),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            '-7.372103200850368, 112.75061827576478',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                              const ClipboardData(
                                text: '-7.372103200850368, 112.75061827576478',
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Koordinat disalin ke clipboard!',
                                ),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: const Icon(Icons.copy, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ===== 3 MENU SAMA UKURAN + OVERLAY 35.3 =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: const [
                    Expanded(
                      child: _MenuCard(
                        label: 'laporkan',
                        asset: 'assets/icons/report.png',
                        fallbackIcon: Icons.receipt_long,
                        overlayAsset:
                            'assets/image_16.png', // <— padanan @drawable/image_16
                        overlaySize: 35.3,
                        overlayAlignment: Alignment.center,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _MenuCard(
                        label: 'Mendaftar\nsukarelawan',
                        asset: 'assets/icons/volunteer.png',
                        fallbackIcon: Icons.volunteer_activism,
                        overlayAsset: 'assets/image_16.png',
                        overlaySize: 35.3,
                        overlayAlignment: Alignment.center,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _MenuCard(
                        label: 'Lokasi\nbermasalah',
                        asset: 'assets/icons/map.png',
                        fallbackIcon: Icons.map_outlined,
                        overlayAsset: 'assets/image_16.png',
                        overlaySize: 35.3,
                        overlayAlignment: Alignment.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ===== LIST LAPORAN =====
              if (reports.isNotEmpty) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'Laporan di daerahmu saat ini',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...reports.map((r) => _ReportTile(report: r)).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/* ===================== MODELS ===================== */

enum ReportStatus { progress, done, pending }

class Report {
  final String coord;
  final String statusLabel;
  final ReportStatus statusKey;
  final String distance;
  Report({
    required this.coord,
    required this.statusLabel,
    required this.statusKey,
    required this.distance,
  });
}

/* ===================== WIDGETS ===================== */

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.label,
    required this.asset,
    this.fallbackIcon,
    this.overlayAsset,
    this.overlaySize,
    this.overlayAlignment,
  });

  final String label;
  final String asset;
  final IconData? fallbackIcon;

  // Overlay (padanan View 35.3dp + background @drawable/image_16)
  final String? overlayAsset;
  final double? overlaySize;
  final Alignment? overlayAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Kartu ikon (ukuran seragam)
        Container(
          height: 82,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ikon utama: pakai asset kalau ada, fallback ke Material Icon
                Image.asset(
                  asset,
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    fallbackIcon ?? Icons.image_not_supported_outlined,
                    size: 36,
                    color: const Color(0xFF5A5F66),
                  ),
                ),

                // Overlay 35.3 × 35.3 (pengganti VectorDrawable @drawable/image_16)
                if (overlayAsset != null)
                  Align(
                    alignment: overlayAlignment ?? Alignment.center,
                    child: SizedBox(
                      width: overlaySize ?? 35.3,
                      height: overlaySize ?? 35.3,
                      child: Image.asset(
                        overlayAsset!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Caption: tinggi dipaku agar “laporkan” (1 baris) sejajar dg label lain (2 baris)
        SizedBox(
          height: 36,
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13.5, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.report});
  final Report report;

  Color get _statusColor {
    switch (report.statusKey) {
      case ReportStatus.progress:
        return const Color(0xFF2E7DF6); // biru
      case ReportStatus.done:
        return const Color(0xFF21B356); // hijau
      case ReportStatus.pending:
        return const Color(0xFFE35247); // merah
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon lokasi bawaan Material (tidak diganti asset)
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(Icons.location_on, size: 28, color: _statusColor),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report.coord,
                        style: const TextStyle(
                          fontSize: 14.2,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: report.coord));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Koordinat disalin'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.copy, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  report.statusLabel,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _statusColor,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Color(0xFF6E7681),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      report.distance,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6E7681),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
