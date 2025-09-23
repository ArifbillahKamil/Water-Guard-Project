import 'package:flutter/material.dart';

class BottomWaveFooter extends StatelessWidget {
  const BottomWaveFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 140,
        width: double.infinity,
        child: CustomPaint(painter: _BottomWavePainter()),
      ),
    );
  }
}

class _BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB2F7EF), Color(0xFF4894FE)],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height * 0.3);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.6,
      size.width * 0.5,
      size.height * 0.4,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.2,
      size.width,
      size.height * 0.4,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
