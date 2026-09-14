import 'package:flutter/material.dart';
import '../../domain/models/plate_data.dart';
import '../../../../core/utils/cvd_simulator.dart';

class IshiharaPlateWidget extends StatelessWidget {
  final PlateData plate;
  final double size;
  final CvdType simulationType;

  const IshiharaPlateWidget({
    super.key,
    required this.plate,
    this.size = 300,
    this.simulationType = CvdType.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1E293B),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            spreadRadius: 4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: CustomPaint(
          size: Size(size, size),
          painter: _PlatePainter(
            dots: plate.dots,
            simulationType: simulationType,
          ),
        ),
      ),
    );
  }
}

class _PlatePainter extends CustomPainter {
  final List<PlateDot> dots;
  final CvdType simulationType;

  _PlatePainter({
    required this.dots,
    required this.simulationType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 2;

    // Paint each dot
    final paint = Paint()..style = PaintingStyle.fill;

    for (final dot in dots) {
      final dotCenter = Offset(
        center.dx + dot.x * scale,
        center.dy + dot.y * scale,
      );
      final dotRadius = dot.radius * scale;

      Color color = dot.color;
      if (simulationType != CvdType.normal) {
        color = CvdSimulator.simulate(color, simulationType);
      }

      paint.color = color;
      canvas.drawCircle(dotCenter, dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PlatePainter oldDelegate) {
    return oldDelegate.dots != dots || oldDelegate.simulationType != simulationType;
  }
}
