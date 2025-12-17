import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. WAJIB IMPORT INI
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
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
        title: Text(
          "privacy_title".tr(), // "Privasi"
          style: const TextStyle(
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
                  buildToggleCard("privacy_location".tr(), aksesLokasi, (val) {
                    // "Akses Lokasi"
                    setState(() => aksesLokasi = val);
                    _updateSetting('privacy_location', val);

                    if (!val) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "privacy_location_warn"
                                .tr(), // "Fitur peta mungkin tidak..."
                          ),
                        ),
                      );
                    }
                  }),
                  const SizedBox(height: 20),

                  // Toggle 2FA
                  buildToggleCard("privacy_2fa".tr(), autentikasi, (val) {
                    // "Authentikasi 2 langkah"
                    setState(() => autentikasi = val);
                    _updateSetting('privacy_2fa', val);
                  }),
                  const SizedBox(height: 20),

                  // Toggle Data
                  buildToggleCard("privacy_data".tr(), izinData, (val) {
                    // "Izin akses data..."
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
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              // Pakai Expanded agar teks panjang tidak error overflow
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
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
