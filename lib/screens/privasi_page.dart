import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import ini
import 'profile_settings_screen.dart';

class PrivasiPage extends StatefulWidget {
  const PrivasiPage({super.key});

  @override
  _PrivasiPageState createState() => _PrivasiPageState();
}

class _PrivasiPageState extends State<PrivasiPage> {
  // Default value
  bool aksesLokasi = true;
  bool autentikasi = false;
  bool izinData = true;
  bool _isLoading = true; // Loading saat baca data awal

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Baca settingan lama saat halaman dibuka
  }

  // --- FUNGSI BACA SETTINGAN DARI HP ---
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      aksesLokasi = prefs.getBool('privacy_location') ?? true;
      autentikasi = prefs.getBool('privacy_2fa') ?? false;
      izinData = prefs.getBool('privacy_data') ?? true;
      _isLoading = false;
    });
  }

  // --- FUNGSI SIMPAN SETTINGAN KE HP ---
  Future<void> _updateSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),

      // ===== APPBAR =====
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
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

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // Toggle Lokasi
                  buildToggleCard("Akses Lokasi", aksesLokasi, (val) {
                    setState(() => aksesLokasi = val);
                    _updateSetting('privacy_location', val);
                    // Opsional: Jika dimatikan, bisa show dialog peringatan
                    if (!val) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Fitur peta mungkin tidak berjalan optimal.',
                          ),
                        ),
                      );
                    }
                  }),
                  const SizedBox(height: 20),

                  // Toggle 2FA
                  buildToggleCard("Authentikasi 2 langkah", autentikasi, (val) {
                    setState(() => autentikasi = val);
                    _updateSetting('privacy_2fa', val);
                  }),
                  const SizedBox(height: 20),

                  // Toggle Data
                  buildToggleCard("Izin akses data perangkat", izinData, (val) {
                    setState(() => izinData = val);
                    _updateSetting('privacy_data', val);
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
              color: Colors.black12, // Dibuat lebih soft (12 bukan 26)
              blurRadius: 10,
              offset: Offset(0, 4),
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
              // Warna aktif disesuaikan dengan tema biru aplikasi (opsional)
              activeColor: const Color(0xFF4894FE),
              activeTrackColor: const Color(0xFFBEE3FF),
              inactiveThumbColor: Colors.grey.shade200,
              inactiveTrackColor: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
