import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import Auth
import 'package:intl/intl.dart'; // Untuk format tanggal

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
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
          title: const Text(
            "Notifikasi",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          // Tombol Debug (Opsional: Bisa dihapus jika tidak butuh)
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
              onPressed: () => _createDummyNotification(user?.uid),
              tooltip: "Buat Notifikasi Test",
            ),
          ],
        ),
      ),
      body: user == null
          ? const Center(child: Text("Silakan login terlebih dahulu"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifikasi')
                  .where('uid_user', isEqualTo: user.uid) // Filter user
                  .orderBy('tanggal', descending: true) // Urutan terbaru
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error Handling agar tidak merah di layar
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Belum ada notifikasi",
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    // Mapping Tipe -> Warna & Icon
                    String type = data['tipe'] ?? 'info';
                    Color themeColor = Colors.blue;
                    IconData iconData = Icons.info;

                    if (type == 'alert') {
                      themeColor = const Color(0xFFE35247); // Merah
                      iconData = Icons.warning_amber_rounded;
                    } else if (type == 'success') {
                      themeColor = const Color(0xFF21B356); // Hijau
                      iconData = Icons.check_circle_outline;
                    } else if (type == 'promo') {
                      themeColor = const Color(0xFF8B5CF6); // Ungu
                      iconData = Icons.local_offer_outlined;
                    }

                    // Format Tanggal
                    String timeAgo = '';
                    if (data['tanggal'] != null) {
                      Timestamp ts = data['tanggal'];
                      timeAgo = DateFormat('dd MMM, HH:mm').format(ts.toDate());
                    }

                    return CustomNotificationCard(
                      title: data['judul'] ?? 'Notifikasi',
                      titleColor: themeColor,
                      subtitleBold: data['sub_judul'] ?? '',
                      message: data['pesan'] ?? '',
                      icon: iconData,
                      iconColor: themeColor,
                      time: timeAgo,
                    );
                  },
                );
              },
            ),
    );
  }

  // Fungsi Debug: Buat Data Dummy
  Future<void> _createDummyNotification(String? uid) async {
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('notifikasi').add({
      'uid_user': uid,
      'judul': 'Status Laporan',
      'sub_judul': 'Test Notifikasi Manual',
      'pesan':
          'Ini adalah notifikasi percobaan. Tombol Tutup sekarang sudah berfungsi!',
      'tipe': 'success',
      'tanggal': FieldValue.serverTimestamp(),
      'is_read': false,
    });
  }
}

// ==========================================
// CARD YANG BISA DI-EXPAND (STATEFUL)
// ==========================================
class CustomNotificationCard extends StatefulWidget {
  final String title;
  final Color titleColor;
  final String subtitleBold;
  final String message;
  final IconData icon;
  final Color iconColor;
  final String time;

  const CustomNotificationCard({
    super.key,
    required this.title,
    required this.titleColor,
    required this.subtitleBold,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.time,
  });

  @override
  State<CustomNotificationCard> createState() => _CustomNotificationCardState();
}

class _CustomNotificationCardState extends State<CustomNotificationCard> {
  bool _isExpanded = false; // Status card (Terbuka/Tertutup)

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ICON ---
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(widget.icon, color: widget.iconColor, size: 22),
                ),
              ),
              const SizedBox(width: 12),

              // --- CONTENT ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: widget.titleColor,
                          ),
                        ),
                        Text(
                          widget.time,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    if (widget.subtitleBold.isNotEmpty)
                      const SizedBox(height: 4),
                    if (widget.subtitleBold.isNotEmpty)
                      Text(
                        widget.subtitleBold,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),

                    // Teks Pesan
                    Text(
                      widget.message,
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      maxLines: _isExpanded ? null : 2, // Logic Expand
                      overflow: _isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // --- TOMBOL PANAH (EXPAND/COLLAPSE) ---
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AnimatedRotation(
                      turns: _isExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: widget.iconColor.withOpacity(0.9),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // --- TOMBOL TUTUP (YANG KITA PERBAIKI) ---
          if (_isExpanded) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // PERBAIKAN DI SINI:
                  setState(() {
                    _isExpanded = false; // Tutup kembali
                  });
                },
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                child: const Text("Tutup", style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
