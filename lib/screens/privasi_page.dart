import 'package:flutter/material.dart';

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan clipPath lengkung
            Stack(
              children: [
                ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4A90E2), Color(0xFF9BE7C4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),

                // Tombol back dan status bar (mock)
                Positioned(
                  top: 20,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 22,
                  left: 60,
                  child: const Text(
                    '5:13 PM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Positioned(
                  top: 22,
                  right: 16,
                  child: Row(
                    children: const [
                      Icon(Icons.alarm, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Icon(Icons.wifi, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Icon(Icons.battery_full, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Judul PRIVASI
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "PRIVASI",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A90E2),
                    letterSpacing: 1,
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.grey,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Toggle list
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
              inactiveTrackColor: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }
}

// =======================
// Custom wave clipper
// =======================
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);

    // Lengkungan halus di bawah header
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 30);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(3 * size.width / 4, size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
