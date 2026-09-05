import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class ConfidenceGauge extends StatelessWidget {
  final int percentage;
  final double size;

  const ConfidenceGauge({
    super.key,
    required this.percentage,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _GaugePainter(percentage: percentage),
          ),
          Text(
            '$percentage%',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final int percentage;

  _GaugePainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 3;

    final bgPaint = Paint()
      ..color = AppColors.primaryBlueLight
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final fgPaint = Paint()
      ..color = AppColors.primaryBlue
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    final sweepAngle = (percentage / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.percentage != percentage;
}
