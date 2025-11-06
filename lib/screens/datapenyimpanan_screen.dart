// lib/screens/data_storage_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Untuk icon

class DataStorageScreen extends StatefulWidget {
  const DataStorageScreen({super.key});

  @override
  State<DataStorageScreen> createState() => _DataStorageScreenState();
}

class _DataStorageScreenState extends State<DataStorageScreen> {
  // Contoh data dummy untuk penggunaan penyimpanan
  double _appSize = 120.5; // MB
  double _cacheSize = 45.2; // MB
  double _totalUsed = 165.7; // MB

  bool _isClearingCache = false;

  Future<void> _clearCache() async {
    setState(() {
      _isClearingCache = true;
    });

    // Simulasi proses membersihkan cache
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _cacheSize = 0.0;
      _totalUsed = _appSize; // Total yang digunakan hanya ukuran aplikasi
      _isClearingCache = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache berhasil dibersihkan!')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF3F5F8,
      ), // Background sama dengan dashboard
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0), // Tinggi AppBar
        child: AppBar(
          automaticallyImplyLeading: false, // Matikan default back button
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4894FE),
                  Color(0xFFB3FEB5),
                ], // Gradient dari dashboard
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
          ),
          title: Text(
            'Data & Penyimpanan',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          elevation: 0, // Hilangkan shadow default AppBar
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Penggunaan Penyimpanan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),

            // Card informasi penyimpanan
            _buildStorageInfoCard(
              context,
              title: 'Ukuran Aplikasi',
              value: '${_appSize.toStringAsFixed(1)} MB',
              icon: Icons.smartphone_outlined,
              color: const Color(0xFF2E7DF6), // Warna biru dari dashboard
            ),
            const SizedBox(height: 12),
            _buildStorageInfoCard(
              context,
              title: 'Cache Aplikasi',
              value: '${_cacheSize.toStringAsFixed(1)} MB',
              icon: Icons.cached_outlined,
              color: const Color(0xFF21B356), // Warna hijau dari dashboard
            ),
            const SizedBox(height: 12),
            _buildStorageInfoCard(
              context,
              title: 'Total Digunakan',
              value: '${_totalUsed.toStringAsFixed(1)} MB',
              icon: Icons.sd_storage_outlined,
              color: const Color(0xFFE35247), // Warna merah dari dashboard
            ),
            const SizedBox(height: 30),

            // Tombol Bersihkan Cache
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isClearingCache ? null : _clearCache,
                icon: _isClearingCache
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        FontAwesomeIcons.broom,
                        size: 20,
                      ), // Icon dari font_awesome_flutter
                label: Text(
                  _isClearingCache
                      ? 'Membersihkan Cache...'
                      : 'Bersihkan Cache',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4894FE), // Warna biru utama
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  shadowColor: const Color(0xFF4894FE).withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageInfoCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Color(0xFF9AA3B2),
          ), // Arrow di paling kanan
        ],
      ),
    );
  }
}
