import 'package:flutter/material.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Gradient Header
            Container(
              height: 160,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF73C0FF), Color(0xFFA8E6CF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
            ),

            // Scrollable Content
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 136, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// SECTION 1
                  _SectionLabel('Bagian 1: Panduan Penggunaan'),
                  const SizedBox(height: 8),
                  _CardSection(
                    children: [
                      _GuideTile(
                        index: 1,
                        leading: Icons.menu_book_rounded,
                        title: 'Cara Menggunakan Aplikasi',
                        description:
                            'Pelajari cara memantau data air, mengontrol katup, dan membaca laporan sensor.',
                        buttonText: 'Lihat Panduan',
                        onPressed: () {},
                      ),
                      const Divider(height: 24),
                      _GuideTile(
                        index: 2,
                        leading: Icons.tune_rounded,
                        title: 'Kalibrasi Sensor',
                        description:
                            'Langkah-langkah untuk mematriksasi sensor tekanan dan debit air berfungsi optimal.',
                        buttonText: 'Buka Tutorial',
                        onPressed: () {},
                      ),
                      const Divider(height: 24),
                      _GuideTile(
                        index: 3,
                        leading: Icons.bolt_rounded,
                        title: 'Tips Penghematan Energi',
                        description:
                            'Optimalkan penggunaan sistem agar hemat daya tanpa mengurangi performa.',
                        buttonText: 'Lihat Tips',
                        onPressed: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  /// SECTION 2
                  const _SectionLabel('Bagian 2: Masalah Umum (FAQ)'),
                  const SizedBox(height: 8),
                  const _FaqAccordion(
                    faqs: [
                      _FaqItem(
                        question: 'Mengapa data sensor tidak muncul?',
                        answer:
                            'Pastikan koneksi internet stabil dan sensor telah tersinkron dengan server pusat.',
                      ),
                      _FaqItem(
                        question:
                            'Bagaimana cara menambah titik pemantauan baru?',
                        answer:
                            'Masuk ke menu Data Sensor → Tambah Titik Baru → Isi koordinat lokasi.',
                      ),
                      _FaqItem(
                        question: 'Aplikasi tidak bisa masuk (login gagal)?',
                        answer:
                            'Periksa koneksi internet, pastikan akun aktif, atau hubungi admin wilayah.',
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  /// SECTION 3
                  const _SectionLabel('Bagian 3: Laporan & Dukungan Teknis'),
                  const SizedBox(height: 8),
                  _CardSection(
                    children: [
                      _GuideTile(
                        index: 1,
                        leading: Icons.report_problem_rounded,
                        title: 'Laporkan Masalah',
                        description:
                            'Temukan bug atau kerusakan sistem air? Kirim laporan ke tim pusat.',
                        buttonText: 'Laporkan Sekarang',
                        onPressed: () {},
                      ),
                      const SizedBox(height: 16),
                      _GuideTile(
                        index: 2,
                        leading: Icons.support_agent_rounded,
                        title: 'Hubungi Admin Teknis',
                        description:
                            'Butuh bantuan langsung? Hubungi admin atau pusat kontrol.',
                        buttonText: 'Chat Admin',
                        onPressed: () {},
                      ),
                      const SizedBox(height: 16),
                      _ContactCard(
                        phoneDisplay: '(021) 800-xxxx',
                        onCall: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  /// SECTION 4
                  const _SectionLabel('Bagian 4: Informasi Tambahan'),
                  const SizedBox(height: 8),
                  const _InfoList(
                    items: [
                      _InfoRow(
                        icon: Icons.privacy_tip_rounded,
                        title: 'Kebijakan Privasi',
                      ),
                      _InfoRow(
                        icon: Icons.description_rounded,
                        title: 'Syarat & Ketentuan',
                      ),
                      _InfoRow(
                        icon: Icons.system_update_rounded,
                        title: 'Versi Aplikasi: v1.0.0 (Beta)',
                      ),
                      _InfoRow(
                        icon: Icons.schedule_rounded,
                        title: 'Terakhir Diperbarui: 20 Oktober 2025',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Top Header with Back Button
            Positioned(
              left: 4,
              top: 8,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Bantuan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .2,
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

/// ===== UI COMPONENTS =====

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.w700, color: cs.primary),
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _GuideTile extends StatelessWidget {
  const _GuideTile({
    required this.index,
    required this.leading,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
  });

  final int index;
  final IconData leading;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10, top: 2),
          child: Text(
            '$index.',
            style: TextStyle(fontWeight: FontWeight.w700, color: cs.primary),
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBadge(icon: leading),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Deskripsi: $description',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton(
                        onPressed: onPressed,
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Tombol: $buttonText'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(.25),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Icon(icon, color: cs.primary, size: 22),
    );
  }
}

/// FAQ ACCORDION

class _FaqAccordion extends StatefulWidget {
  const _FaqAccordion({required this.faqs});
  final List<_FaqItem> faqs;

  @override
  State<_FaqAccordion> createState() => _FaqAccordionState();
}

class _FaqAccordionState extends State<_FaqAccordion> {
  late List<bool> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = List<bool>.filled(widget.faqs.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            for (int i = 0; i < widget.faqs.length; i++) ...[
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: Colors.transparent),
                  ),
                  onExpansionChanged: (v) => setState(() => _expanded[i] = v),
                  leading: _IconBadge(
                    icon: _expanded[i]
                        ? Icons.help_outline_rounded
                        : Icons.help_rounded,
                  ),
                  title: Text(
                    '${i + 1}. ${widget.faqs[i].question}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(64, 0, 16, 16),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Jawaban: ${widget.faqs[i].answer}',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (i != widget.faqs.length - 1)
                Divider(height: 0, color: Colors.grey.shade200),
            ],
          ],
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}

/// CONTACT CARD

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.phoneDisplay, required this.onCall});

  final String phoneDisplay;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _IconBadge(icon: Icons.phone_in_talk_rounded),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kontak Darurat',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  'Nomor: $phoneDisplay',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40, maxWidth: 180),
            child: ElevatedButton.icon(
              onPressed: onCall,
              icon: const Icon(Icons.call_rounded, size: 18),
              label: const Text('Panggil'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(0, 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// INFO LIST

class _InfoList extends StatelessWidget {
  const _InfoList({required this.items});
  final List<_InfoRow> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i != items.length - 1)
              Divider(height: 0, color: Colors.grey.shade200),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.title, this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _IconBadge(icon: icon),
      title: Text(title),
      trailing: onTap != null ? const Icon(Icons.chevron_right_rounded) : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    );
  }
}
