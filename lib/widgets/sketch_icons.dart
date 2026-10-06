import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HouseSketchIcon extends StatelessWidget {
  final double size;
  const HouseSketchIcon({super.key, this.size = 64});
  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(size, size), painter: _HousePainter());
}

class _HousePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roofPaint = Paint()
      ..color = AppColors.clay
      ..strokeWidth = size.width * 0.045
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final bodyPaint = Paint()
      ..color = AppColors.ink
      ..strokeWidth = size.width * 0.045
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width, h = size.height;

    final roof = Path()
      ..moveTo(w * 0.15, h * 0.475)
      ..lineTo(w * 0.5, h * 0.175)
      ..lineTo(w * 0.85, h * 0.475);
    canvas.drawPath(roof, roofPaint);

    final body = Path()
      ..moveTo(w * 0.25, h * 0.4125)
      ..lineTo(w * 0.25, h * 0.8)
      ..lineTo(w * 0.75, h * 0.8)
      ..lineTo(w * 0.75, h * 0.4125);
    canvas.drawPath(body, bodyPaint);

    final door = Rect.fromLTWH(w * 0.4375, h * 0.575, w * 0.125, h * 0.225);
    canvas.drawRect(door, Paint()
      ..color = AppColors.ink
      ..strokeWidth = size.width * 0.032
      ..style = PaintingStyle.stroke);

    final window = Rect.fromLTWH(w * 0.575, h * 0.575, w * 0.125, h * 0.1);
    canvas.drawRect(window, bodyPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MoneySketchIcon extends StatelessWidget {
  final double size;
  const MoneySketchIcon({super.key, this.size = 64});
  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(size, size), painter: _MoneyPainter());
}

class _MoneyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final greenPaint = Paint()
      ..color = AppColors.green
      ..strokeWidth = size.width * 0.04
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final inkPaint = Paint()
      ..color = AppColors.ink
      ..strokeWidth = size.width * 0.03
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: size.width * 0.6, height: size.height * 0.425),
      greenPaint,
    );
    canvas.drawCircle(center, size.width * 0.175, inkPaint);
    canvas.drawLine(Offset(size.width * 0.175, center.dy), Offset(size.width * 0.125, center.dy), greenPaint);
    canvas.drawLine(Offset(size.width * 0.875, center.dy), Offset(size.width * 0.825, center.dy), greenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SettingsSketchIcon extends StatelessWidget {
  final double size;
  const SettingsSketchIcon({super.key, this.size = 64});
  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(size, size), painter: _SettingsPainter());
}

class _SettingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final inkPaint = Paint()
      ..color = AppColors.ink
      ..strokeWidth = size.width * 0.045
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final clayPaint = Paint()
      ..color = AppColors.clay
      ..strokeWidth = size.width * 0.048
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width * 0.125, inkPaint);

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * pi / 180;
      final innerR = size.width * 0.29;
      final outerR = size.width * 0.375;
      final p1 = center + Offset(innerR * cos(angle), innerR * sin(angle));
      final p2 = center + Offset(outerR * cos(angle), outerR * sin(angle));
      canvas.drawLine(p1, p2, clayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
