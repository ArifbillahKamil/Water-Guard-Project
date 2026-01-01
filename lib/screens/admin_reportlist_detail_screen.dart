import 'dart:convert'; // 1. WAJIB ADA
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminReportDetailScreen extends StatefulWidget {
  final String reportId;
  final Map<String, dynamic> data;
  final String userRole;

  const AdminReportDetailScreen({
    super.key,
    required this.reportId,
    required this.data,
    required this.userRole,
  });

  @override
  State<AdminReportDetailScreen> createState() =>
      _AdminReportDetailScreenState();
}

class _AdminReportDetailScreenState extends State<AdminReportDetailScreen> {
  late String _currentStatus;
  bool _isUpdating = false;

  final List<String> _statusOptions = [
    'Menunggu',
    'Diproses',
    'Selesai',
    'Ditolak',
  ];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.data['status'] ?? 'Menunggu';
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    try {
      await FirebaseFirestore.instance
          .collection('laporan')
          .doc(widget.reportId)
          .update({'status': newStatus});

      setState(() => _currentStatus = newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Status berhasil diperbarui!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- LOGIKA GAMBAR BASE64 ---
    String? base64String = widget.data['foto_base64'];
    Widget imageWidget;

    if (base64String != null && base64String.isNotEmpty) {
      try {
        imageWidget = Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
        );
      } catch (e) {
        imageWidget = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.broken_image, size: 50, color: Colors.grey),
            Text("Gambar rusak"),
          ],
        );
      }
    } else {
      imageWidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
          Text("Tidak ada foto"),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Laporan"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. FOTO LAPORAN
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[300],
              child: imageWidget, // Tampilkan widget gambar yang sudah diproses
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. JUDUL
                  Text(
                    widget.data['judul'] ?? "Tanpa Judul",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 3. PELAPOR
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "Pelapor: ${widget.data['nama_pelapor'] ?? 'Anonim'}",
                        style: GoogleFonts.poppins(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),

                  // 4. DESKRIPSI
                  Text(
                    "Deskripsi:",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.data['deskripsi'] ?? "Tidak ada deskripsi.",
                    style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),

                  // 5. UPDATE STATUS
                  Text(
                    "Update Status Laporan",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  if (widget.userRole == 'admin')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _statusOptions.contains(_currentStatus)
                              ? _currentStatus
                              : null,
                          isExpanded: true,
                          hint: Text(_currentStatus),
                          items: _statusOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: GoogleFonts.poppins()),
                            );
                          }).toList(),
                          onChanged: _isUpdating
                              ? null
                              : (newValue) {
                                  if (newValue != null &&
                                      newValue != _currentStatus) {
                                    _updateStatus(newValue);
                                  }
                                },
                        ),
                      ),
                    )
                  else
                    // TAMPILAN RELAWAN (READ ONLY)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock, size: 16, color: Colors.grey),
                          const SizedBox(width: 10),
                          Text(
                            "Status: $_currentStatus",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
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
    );
  }
}
