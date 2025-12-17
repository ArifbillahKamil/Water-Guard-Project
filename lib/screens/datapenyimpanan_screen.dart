import 'dart:io'; // Untuk akses File System
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. WAJIB IMPORT INI

class DataStorageScreen extends StatefulWidget {
  const DataStorageScreen({super.key});

  @override
  State<DataStorageScreen> createState() => _DataStorageScreenState();
}

class _DataStorageScreenState extends State<DataStorageScreen> {
  // Variabel Data Real
  String _cacheSizeStr = "0.0 MB";
  double _cacheSizeBytes = 0;
  bool _isLoading = false;

  // Data Statis
  final String _appSizeStr = "45.0 MB";

  @override
  void initState() {
    super.initState();
    _checkCacheSize();
  }

  // --- LOGIKA BACKEND MENGHITUNG CACHE ---
  Future<void> _checkCacheSize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      double totalSize = 0;

      if (tempDir.existsSync()) {
        tempDir.listSync(recursive: true, followLinks: false).forEach((
          FileSystemEntity entity,
        ) {
          if (entity is File) {
            totalSize += entity.lengthSync();
          }
        });
      }

      setState(() {
        _cacheSizeBytes = totalSize;
        _cacheSizeStr = _formatBytes(totalSize);
      });
    } catch (e) {
      debugPrint("Gagal menghitung cache: $e");
    }
  }

  // --- LOGIKA BACKEND MENGHAPUS CACHE ---
  Future<void> _clearCache() async {
    setState(() => _isLoading = true);

    try {
      final tempDir = await getTemporaryDirectory();

      if (tempDir.existsSync()) {
        final dir = Directory(tempDir.path);
        dir.listSync().forEach((FileSystemEntity entity) {
          try {
            entity.deleteSync(recursive: true);
          } catch (e) {
            // Abaikan file yang dikunci sistem
          }
        });
      }

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "storage_clean_success".tr(),
            ), // "File sampah berhasil dibersihkan!"
            backgroundColor: Colors.green,
          ),
        );
        await _checkCacheSize();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${'storage_error'.tr()}$e")), // "Gagal: ..."
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- HELPER: Mengubah Bytes ke MB/GB ---
  String _formatBytes(double bytes) {
    if (bytes <= 0) return "0.0 MB";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = 0;
    while (bytes >= 1024 && i < suffixes.length - 1) {
      bytes /= 1024;
      i++;
    }
    return '${bytes.toStringAsFixed(1)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black54),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "storage_title".tr(), // "Data dan penyimpanan"
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "storage_usage".tr(), // "Penggunaan Penyimpanan"
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),

            // Card 1: Ukuran Aplikasi
            _buildStorageInfoCard(
              context,
              title: "storage_app_size".tr(), // "Ukuran Aplikasi"
              value: _appSizeStr,
              icon: Icons.smartphone_outlined,
              color: const Color(0xFF2E7DF6),
            ),
            const SizedBox(height: 12),

            // Card 2: Cache
            _buildStorageInfoCard(
              context,
              title: "storage_cache".tr(), // "Cache & File Sampah"
              value: _cacheSizeStr,
              icon: Icons.cached_outlined,
              color: const Color(0xFF21B356),
            ),
            const SizedBox(height: 12),

            // Card 3: Total
            _buildStorageInfoCard(
              context,
              title: "storage_total".tr(), // "Total Data"
              value: _isLoading
                  ? "storage_calculating"
                        .tr() // "Menghitung..."
                  : _cacheSizeStr,
              icon: Icons.sd_storage_outlined,
              color: const Color(0xFFE35247),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_isLoading || _cacheSizeBytes == 0)
                    ? null
                    : _clearCache,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(FontAwesomeIcons.broom, size: 20),
                label: Text(
                  _isLoading
                      ? "storage_clearing"
                            .tr() // "Membersihkan..."
                      : "storage_btn_clear".tr(), // "Bersihkan Cache"
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4894FE),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                ),
              ),
            ),

            // Info tambahan jika bersih
            if (_cacheSizeBytes == 0 && !_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    "storage_clean_optimal"
                        .tr(), // "Penyimpanan bersih optimal!"
                    style: TextStyle(color: Colors.green[600], fontSize: 12),
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
        ],
      ),
    );
  }
}
