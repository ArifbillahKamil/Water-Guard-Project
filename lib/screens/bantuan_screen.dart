import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.8,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Bantuan",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==============================
          // Search Help
          // ==============================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: TextField(
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                icon: const Icon(Icons.search, color: Colors.black45),
                hintText: "Cari pertanyaan...",
                hintStyle: GoogleFonts.poppins(color: Colors.black38),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 22),

          // ==============================
          // Quick Help Sections
          // ==============================
          Text(
            "Kategori Bantuan",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          _helpCategory(Icons.sensors, "Sensor & Data"),
          _helpCategory(Icons.account_circle, "Akun & Login"),
          _helpCategory(Icons.settings, "Pengaturan Sistem"),
          _helpCategory(Icons.report_problem, "Masalah Teknis"),

          const SizedBox(height: 26),

          // ==============================
          // Frequently Asked Questions
          // ==============================
          Text(
            "FAQ Populer",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          _faqItem("Mengapa data tidak muncul di Dashboard?"),
          _faqItem("Bagaimana cara menghubungkan sensor baru?"),
          _faqItem("Bagaimana jika aplikasi tidak merespon?"),

          const SizedBox(height: 26),

          // ==============================
          // Support Contact Block
          // ==============================
          Text(
            "Butuh Bantuan Langsung?",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tim Dukungan WaterGuard",
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Kami siap membantu kapan saja.",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      _contactButton(Icons.chat, "Chat Admin"),
                      const SizedBox(width: 10),
                      _contactButton(Icons.email, "Email"),
                      const SizedBox(width: 10),
                      _contactButton(Icons.phone, "Telepon"),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 26),

          Center(
            child: Text(
              "Versi Aplikasi: 1.0.0",
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _helpCategory(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 13.5)),
        trailing: const Icon(Icons.chevron_right, color: Colors.black54),
        onTap: () {},
      ),
    );
  }

  Widget _faqItem(String text) {
    return ExpansionTile(
      iconColor: Colors.black87,
      collapsedIconColor: Colors.black87,
      tilePadding: EdgeInsets.zero,
      title: Text(text, style: GoogleFonts.poppins(fontSize: 13)),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            "Jawaban akan ditampilkan di sini.",
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _contactButton(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: Colors.black87),
            const SizedBox(height: 4),
            Text(
              text,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
