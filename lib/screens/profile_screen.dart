import 'package:flutter/material.dart';
import '../widgets/double_wave_header.dart';
import '../widgets/bottom_wave_footer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController(
    text: "Jonathan",
  );
  final TextEditingController birthController = TextEditingController(
    text: "05 Mei 2002",
  );
  final TextEditingController genderController = TextEditingController(
    text: "Laki - Laki",
  );
  final TextEditingController phoneController = TextEditingController(
    text: "0849-1837-1283",
  );
  final String email = "Jonathan03@gmail.com";

  @override
  void dispose() {
    nameController.dispose();
    birthController.dispose();
    genderController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  InputDecoration fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      // lebih kecil agar total muat
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFF4894FE), width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFF2E79F8), width: 1.8),
      ),
    );
  }

  // terima tinggi agar tiap field tidak melebihi ruang yang tersedia
  Widget labeledField(
    String label,
    TextEditingController controller, {
    required double height,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SizedBox(
              height: height,
              child: TextFormField(
                controller: controller,
                decoration: fieldDecoration(),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Stack(
        children: [
          const DoubleWaveHeader(),
          const BottomWaveFooter(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;
                // lebih kecil agar layout pas
                final avatarRadius = (h * 0.07).clamp(30.0, 46.0);
                final gap = (h * 0.008).clamp(4.0, 10.0);

                // perkiraan tinggi area atas (icon + title + avatar + name + email + tombol + gaps)
                final topEstimate = avatarRadius * 2 + 130.0;
                // sisa tinggi untuk 4 field
                final availableForFields = (h - topEstimate).clamp(160.0, h);
                final fieldHeight = (availableForFields / 4).clamp(42.0, 56.0);

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: h * 0.03,
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black87,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(height: gap),
                      // Title
                      Text(
                        "My profile",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4894FE),
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(1, 3),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: gap),
                      // Avatar
                      CircleAvatar(
                        radius: avatarRadius,
                        backgroundColor: const Color(0xFFD9EAFD),
                        backgroundImage: const NetworkImage(
                          'https://i.pravatar.cc/300?img=65',
                        ),
                      ),
                      SizedBox(height: gap),
                      Text(
                        nameController.text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: gap / 2),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      SizedBox(height: gap),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEEF6FF),
                          foregroundColor: const Color(0xFF4894FE),
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Edit profile",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: gap * 1.1),
                      // Fields: gunakan Flexible agar tidak overflow, tapi batasi tiap field dengan fieldHeight
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            labeledField(
                              "Nama",
                              nameController,
                              height: fieldHeight,
                            ),
                            labeledField(
                              "Tanggal lahir",
                              birthController,
                              height: fieldHeight,
                            ),
                            labeledField(
                              "Jenis kelamin",
                              genderController,
                              height: fieldHeight,
                            ),
                            labeledField(
                              "Telepon",
                              phoneController,
                              height: fieldHeight,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
