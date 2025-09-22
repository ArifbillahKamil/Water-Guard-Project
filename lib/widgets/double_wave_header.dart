import 'package:flutter/material.dart';

/// Widget untuk gelombang di bagian atas
class DoubleWaveHeader extends StatelessWidget {
  const DoubleWaveHeader({super.key, this.height = 180});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          // Gelombang lapisan bawah (biru tua)
          ClipPath(
            clipper: TopWaveClipper(offset: -30),
            child: Container(
              height: height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(202, 72, 148, 254),
                    Color.fromARGB(199, 179, 254, 182),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Gelombang lapisan atas (biru muda)
          ClipPath(
            clipper: TopWaveClipper(offset: 8),
            child: Container(
              height: height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4894FE), Color(0xFFB3FEB5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- CLIPPERS UNTUK GELOMBANG ATAS ---
class TopWaveClipper extends CustomClipper<Path> {
  TopWaveClipper({this.offset = 0});
  final double offset;

  @override
  Path getClip(Size size) {
    final path = Path();
    final double h = size.height;

    path.lineTo(0, h * 0.7 - offset);
    path.cubicTo(
      size.width * 0.25,
      h * 1 - offset,
      size.width * 0.3,
      h * 0.45 - offset,
      size.width * 0.7,
      h * 0.45 - offset,
    );
    path.quadraticBezierTo(
      size.width * 0.85,
      h * 0.45 - offset,
      size.width,
      h * 0.55 - offset,
    );
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
