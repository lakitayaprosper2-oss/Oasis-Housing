import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusDot extends StatelessWidget {
  final bool overdue;
  final double size;
  const StatusDot({super.key, required this.overdue, this.size = 10});

  @override
  Widget build(BuildContext context) {
    final color = overdue ? AppColors.red : AppColors.green;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color.withOpacity(0.18), spreadRadius: size * 0.3)],
      ),
    );
  }
}
