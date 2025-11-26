import 'package:flutter/material.dart';
import 'profile_settings_screen.dart'; // pastikan ada import ini

class PrivasiPage extends StatefulWidget {
  const PrivasiPage({super.key});

  @override
  _PrivasiPageState createState() => _PrivasiPageState();
}

class _PrivasiPageState extends State<PrivasiPage> {
  bool aksesLokasi = true;
  bool autentikasi = true;
  bool izinData = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),

      // ===== APPBAR BARU =====
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black54),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileSettingsScreen(),
                  ),
                );
              }
            },
          ),
          title: const Text(
            "Privasi",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),

            buildToggleCard("Akses Lokasi", aksesLokasi, (val) {
              setState(() => aksesLokasi = val);
            }),
            const SizedBox(height: 20),

            buildToggleCard("Authentikasi 2 langkah", autentikasi, (val) {
              setState(() => autentikasi = val);
            }),
            const SizedBox(height: 20),

            buildToggleCard("Izin akses data perangkat", izinData, (val) {
              setState(() => izinData = val);
            }),
          ],
        ),
      ),
    );
  }

  Widget buildToggleCard(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: Colors.greenAccent,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
