import 'dart:convert'; // Wajib untuk gambar Base64
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'admin_reportlist_detail_screen.dart';

class AdminReportListScreen extends StatelessWidget {
  final String userRole;

  const AdminReportListScreen({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    // --- LOGIKA JUDUL SESUAI ROLE ---
    String titleKey = userRole == 'volunteer'
        ? 'title_role_volunteer' // "Pantauan Laporan (Relawan)"
        : 'title_role_admin'; // "Panel Laporan (Admin)"

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      appBar: AppBar(
        // Tampilkan judul sesuai logika di atas
        title: Text(
          titleKey.tr(),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 18, // Sedikit disesuaikan agar muat
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('laporan')
            .orderBy('tanggal_lapor', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "Belum ada laporan masuk.",
                style: GoogleFonts.poppins(),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String docId = docs[index].id;

              String status = data['status'] ?? 'Menunggu';

              Color statusColor = Colors.orange;
              if (status == 'Diproses' || status == 'Sedang Proses')
                statusColor = Colors.blue;
              if (status == 'Selesai') statusColor = Colors.green;
              if (status == 'Ditolak') statusColor = Colors.red;

              String dateStr = '-';
              if (data['tanggal_lapor'] != null) {
                Timestamp ts = data['tanggal_lapor'];
                dateStr = DateFormat('dd MMM, HH:mm').format(ts.toDate());
              }

              // --- LOGIKA GAMBAR BASE64 (Aman) ---
              String? base64String = data['foto_base64'];
              Widget imageWidget;

              if (base64String != null && base64String.isNotEmpty) {
                try {
                  imageWidget = Image.memory(
                    base64Decode(base64String),
                    fit: BoxFit.cover,
                  );
                } catch (e) {
                  imageWidget = const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                  );
                }
              } else {
                imageWidget = const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                );
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: imageWidget,
                    ),
                  ),
                  title: Text(
                    data['judul'] ?? 'Laporan Warga',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: statusColor.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 10,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminReportDetailScreen(
                          reportId: docId,
                          data: data,
                          userRole: userRole,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
