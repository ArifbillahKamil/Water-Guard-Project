import 'dart:convert';
import 'dart:io'; // Untuk File Operation
import 'dart:typed_data'; // Untuk Uint8List
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart'; // Import Baru
import 'package:open_filex/open_filex.dart'; // Import Baru

class AdminVolunteerListScreen extends StatefulWidget {
  const AdminVolunteerListScreen({super.key});

  @override
  State<AdminVolunteerListScreen> createState() =>
      _AdminVolunteerListScreenState();
}

class _AdminVolunteerListScreenState extends State<AdminVolunteerListScreen> {
  bool _isOpeningFile = false; // Loading saat buka file

  // --- FUNGSI BUKA FILE DARI BASE64 ---
  Future<void> _openBase64File(String? base64String, String? fileName) async {
    if (base64String == null || base64String.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Data file kosong/rusak")));
      return;
    }

    setState(() => _isOpeningFile = true);

    try {
      // 1. Decode Base64 jadi Bytes
      Uint8List bytes = base64Decode(base64String);

      // 2. Cari Folder Sementara (Cache) di HP
      final output = await getTemporaryDirectory();

      // 3. Buat Nama File (Pastikan ada ekstensi .pdf / .jpg)
      // Jika fileName null, kita tebak default .pdf
      String name = fileName ?? "dokumen_cv.pdf";

      // Bersihkan nama file dari karakter aneh
      name = name.replaceAll(RegExp(r'[^\w\s\.]'), '_');

      final file = File("${output.path}/$name");

      // 4. Tulis Bytes ke File
      await file.writeAsBytes(bytes);

      // 5. Perintahkan HP untuk membuka file tersebut
      final result = await OpenFilex.open(file.path);

      if (result.type != ResultType.done) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal membuka file: ${result.message}")),
          );
      }
    } catch (e) {
      debugPrint("Error buka file: $e");
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Terjadi kesalahan saat membuka file")),
        );
    } finally {
      if (mounted) setState(() => _isOpeningFile = false);
    }
  }

  // Fungsi Approve (Sama seperti sebelumnya)
  Future<void> _approveVolunteer(
    String docId,
    String uidUser,
    String nama,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('pendaftaran_relawan')
          .doc(docId)
          .update({'status': 'Diterima'});
      await FirebaseFirestore.instance.collection('users').doc(uidUser).update({
        'role': 'volunteer',
      });
      await FirebaseFirestore.instance.collection('notifikasi').add({
        'uid_user': uidUser,
        'judul': 'Selamat!',
        'sub_judul': 'Lamaran Diterima',
        'pesan': 'Selamat $nama, Anda resmi menjadi Relawan WaterGuard.',
        'tipe': 'success',
        'tanggal': FieldValue.serverTimestamp(),
        'is_read': false,
      });
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Relawan diterima!'),
            backgroundColor: Colors.green,
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  // Fungsi Reject (Sama seperti sebelumnya)
  Future<void> _rejectVolunteer(
    String docId,
    String uidUser,
    String nama,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('pendaftaran_relawan')
          .doc(docId)
          .update({'status': 'Ditolak'});
      await FirebaseFirestore.instance.collection('notifikasi').add({
        'uid_user': uidUser,
        'judul': 'Pendaftaran Relawan',
        'sub_judul': 'Mohon Maaf',
        'pesan': 'Halo $nama, mohon maaf lamaran Anda belum dapat kami terima.',
        'tipe': 'alert',
        'tanggal': FieldValue.serverTimestamp(),
        'is_read': false,
      });
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lamaran ditolak.'),
            backgroundColor: Colors.orange,
          ),
        );
    } catch (e) {
      debugPrint("Error reject: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      appBar: AppBar(
        title: Text(
          "Kelola Pendaftar",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pendaftaran_relawan')
                .orderBy('tgl_daftar', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                return Center(
                  child: Text(
                    "Belum ada pendaftar.",
                    style: GoogleFonts.poppins(),
                  ),
                );

              final docs = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final docId = docs[index].id;

                  String status = data['status'] ?? 'Menunggu Review';
                  String nama = data['nama_lengkap'] ?? 'Tanpa Nama';
                  String uidUser = data['uid'] ?? '';
                  String? base64CV = data['file_cv_base64'];
                  String? fileName = data['nama_file_cv'];

                  Color statusColor = Colors.orange;
                  if (status == 'Diterima') statusColor = Colors.green;
                  if (status == 'Ditolak') statusColor = Colors.red;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: statusColor.withOpacity(0.1),
                        child: Icon(Icons.person, color: statusColor),
                      ),
                      title: Text(
                        nama,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        status,
                        style: GoogleFonts.poppins(
                          color: statusColor,
                          fontSize: 12,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _detailRow("Email", data['email_kontak'] ?? '-'),
                              _detailRow("HP", data['no_hp'] ?? '-'),
                              _detailRow(
                                "Pendidikan",
                                data['pendidikan'] ?? '-',
                              ),
                              const SizedBox(height: 12),
                              const Divider(),
                              const Text(
                                "Dokumen Pendukung:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),

                              // --- TOMBOL LIHAT CV ---
                              InkWell(
                                onTap: () =>
                                    _openBase64File(base64CV, fileName),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.blue.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.description,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              fileName ?? "Dokumen CV",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const Text(
                                              "Ketuk untuk membuka file",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.open_in_new,
                                        size: 18,
                                        color: Colors.blue,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // -----------------------
                              const SizedBox(height: 20),
                              if (status == 'Menunggu Review')
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _rejectVolunteer(
                                          docId,
                                          uidUser,
                                          nama,
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text("Tolak"),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _approveVolunteer(
                                          docId,
                                          uidUser,
                                          nama,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text("Terima"),
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
                },
              );
            },
          ),

          // Loading Overlay saat buka file
          if (_isOpeningFile)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "Membuka Dokumen...",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
