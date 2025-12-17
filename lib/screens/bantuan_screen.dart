import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart'; // Import Bahasa

class BantuanScreen extends StatefulWidget {
  const BantuanScreen({super.key});

  @override
  State<BantuanScreen> createState() => _BantuanScreenState();
}

class _BantuanScreenState extends State<BantuanScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "";
  List<Map<String, String>> _currentDisplayedFaqs = [];

  // ==========================================
  // 1. EDIT KONTAK DISINI (SESUAIKAN NOMORMU)
  // ==========================================
  // Ganti angka 628... dengan nomor WA aslimu
  final String _whatsappUrl = "https://wa.me/6281237700078";

  // Ganti alamat email
  final String _emailUrl =
      "mailto:arifbillahk03@gmail.com?subject=Bantuan Aplikasi";

  // Ganti nomor telepon biasa
  final String _phoneUrl = "tel:+6281237700078";

  // ==========================================
  // 2. DATA FAQ (BAHASA INDONESIA)
  // ==========================================
  final List<Map<String, String>> _faqsID = [
    {
      "category": "Laporan",
      "question": "Bagaimana cara mengirim laporan?",
      "answer":
          "Pergi ke Dashboard, klik menu 'Laporkan', isi foto bukti dan detail lokasi.",
    },
    {
      "category": "Laporan",
      "question": "Berapa lama laporan diproses?",
      "answer": "Biasanya laporan akan diverifikasi dalam 1x24 jam.",
    },
    {
      "category": "Akun",
      "question": "Apakah data saya aman?",
      "answer": "Tentu. Kami menggunakan enkripsi data standar industri.",
    },
    {
      "category": "Akun",
      "question": "Cara ganti bahasa?",
      "answer": "Masuk ke Profil > Pengaturan > Bahasa.",
    },
    {
      "category": "Relawan",
      "question": "Syarat relawan?",
      "answer": "Warga negara Indonesia, usia minimal 17 tahun.",
    },
    {
      "category": "Relawan",
      "question": "Cara upload CV?",
      "answer": "Format PDF atau DOCX maksimal 1MB.",
    },
    {
      "category": "Sistem",
      "question": "Aplikasi Force Close?",
      "answer": "Pastikan memori cukup dan coba bersihkan Cache.",
    },
    {
      "category": "Sistem",
      "question": "Lokasi tidak akurat?",
      "answer": "Pastikan berada di ruang terbuka agar GPS optimal.",
    },
  ];

  // ==========================================
  // 3. DATA FAQ (BAHASA INGGRIS)
  // ==========================================
  final List<Map<String, String>> _faqsEN = [
    {
      "category": "Report",
      "question": "How to submit a report?",
      "answer":
          "Go to Dashboard, click 'Report', fill in photo proof and location details.",
    },
    {
      "category": "Report",
      "question": "How long is the process?",
      "answer": "Usually reports are verified within 24 hours.",
    },
    {
      "category": "Account",
      "question": "Is my data safe?",
      "answer": "Yes. We use industry standard data encryption.",
    },
    {
      "category": "Account",
      "question": "Change language?",
      "answer": "Go to Profile > Settings > Language.",
    },
    {
      "category": "Volunteer",
      "question": "Volunteer requirements?",
      "answer": "Indonesian citizen, minimum 17 years old.",
    },
    {
      "category": "Volunteer",
      "question": "How to upload CV?",
      "answer": "PDF or DOCX format, max 1MB.",
    },
    {
      "category": "System",
      "question": "App Force Close?",
      "answer": "Ensure enough memory and try clearing Cache.",
    },
    {
      "category": "System",
      "question": "Inaccurate Location?",
      "answer": "Ensure you are outdoors for better GPS signal.",
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset list saat bahasa berubah atau pertama kali buka
    _resetFilter();
  }

  // --- LOGIKA MENGAMBIL DATA SESUAI BAHASA ---
  List<Map<String, String>> get _activeDataSource {
    // Cek bahasa aktif (id / en)
    return context.locale.languageCode == 'en' ? _faqsEN : _faqsID;
  }

  // --- LOGIKA FILTER ---
  void _resetFilter() {
    setState(() {
      _selectedCategory = "";
      _searchController.clear();
      _currentDisplayedFaqs = _activeDataSource;
    });
  }

  void _filterByCategory(String categoryKey) {
    // Kita translate dulu kategory kuncinya biar cocok dengan data
    // Misal tombol "cat_report" -> jadi "Laporan" (ID) atau "Report" (EN)
    String localizedCategory = categoryKey.tr();

    setState(() {
      _searchController.clear();
      if (_selectedCategory == localizedCategory) {
        _selectedCategory = "";
        _currentDisplayedFaqs = _activeDataSource;
      } else {
        _selectedCategory = localizedCategory;
        _currentDisplayedFaqs = _activeDataSource.where((faq) {
          return faq['category'] == localizedCategory;
        }).toList();
      }
    });
  }

  void _runSearchFilter(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        if (_selectedCategory.isNotEmpty) {
          String localizedCategory = _selectedCategory; // Sudah diterjemahkan
          _currentDisplayedFaqs = _activeDataSource
              .where((faq) => faq['category'] == localizedCategory)
              .toList();
        } else {
          _currentDisplayedFaqs = _activeDataSource;
        }
      } else {
        _currentDisplayedFaqs = _activeDataSource
            .where(
              (faq) => faq["question"]!.toLowerCase().contains(
                keyword.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  // --- LOGIKA URL LAUNCHER ---
  Future<void> _launchContact(String type) async {
    Uri? url;
    if (type == "wa") url = Uri.parse(_whatsappUrl);
    if (type == "mail") url = Uri.parse(_emailUrl);
    if (type == "tel") url = Uri.parse(_phoneUrl);

    if (url != null) {
      try {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "help_title".tr(), // Localized Title
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "help_header".tr(), // Localized Header
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 20),

            // SEARCH BAR
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _runSearchFilter,
                decoration: InputDecoration(
                  hintText: "help_search_hint".tr(), // Localized Hint
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF4894FE),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // KATEGORI (Menggunakan Key JSON)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuickCategory(Icons.security, "cat_account"),
                _buildQuickCategory(Icons.description, "cat_report"),
                _buildQuickCategory(
                  FontAwesomeIcons.handshake,
                  "cat_volunteer",
                ),
                _buildQuickCategory(Icons.settings, "cat_system"),
              ],
            ),
            const SizedBox(height: 30),

            // HEADER FILTER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCategory.isEmpty
                      ? "help_all_questions".tr()
                      : "${'help_topic_prefix'.tr()} $_selectedCategory",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                if (_selectedCategory.isNotEmpty)
                  GestureDetector(
                    onTap: _resetFilter,
                    child: Text(
                      "help_reset".tr(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF4894FE),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // LIST FAQ
            _currentDisplayedFaqs.isNotEmpty
                ? Column(
                    children: _currentDisplayedFaqs
                        .map(
                          (faq) =>
                              _buildFaqTile(faq['question']!, faq['answer']!),
                        )
                        .toList(),
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 50,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "help_not_found".tr(),
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 30),

            // CONTACT CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4894FE), Color(0xFF6BAAFC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4894FE).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "help_contact_title".tr(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "help_contact_desc".tr(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildContactBtn(
                        FontAwesomeIcons.whatsapp,
                        "btn_chat",
                        () => _launchContact("wa"),
                      ),
                      _buildContactBtn(
                        Icons.email_outlined,
                        "btn_email",
                        () => _launchContact("mail"),
                      ),
                      _buildContactBtn(
                        Icons.phone_outlined,
                        "btn_call",
                        () => _launchContact("tel"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCategory(IconData icon, String jsonKey) {
    // Terjemahkan key JSON menjadi teks yang tampil
    String label = jsonKey.tr();
    bool isSelected = _selectedCategory == label;

    return GestureDetector(
      onTap: () =>
          _filterByCategory(jsonKey), // Kirim key, nanti di fungsi di-translate
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4894FE) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? const Color(0xFF4894FE).withOpacity(0.4)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: isSelected ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF4894FE),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF4894FE)
                  : const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: const Color(0xFF4894FE),
          collapsedIconColor: Colors.black54,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactBtn(IconData icon, String jsonKey, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF4894FE)),
            const SizedBox(width: 8),
            Text(
              jsonKey.tr(), // Translate tombol
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4894FE),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
