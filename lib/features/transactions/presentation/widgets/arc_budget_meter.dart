import 'dart:math' as math;

import 'package:flutter/material.dart';

class ArcBudgetMeter extends StatelessWidget {
  const ArcBudgetMeter({
    required this.progress,
    required this.expenses,
    required this.budget,
    super.key,
  });

  final double progress;
  final double expenses;
  final double budget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 176,
      child: CustomPaint(
        painter: ArcBudgetPainter(
          progress: progress,
          trackColor: theme.colorScheme.surfaceContainerHighest,
          progressColor: Color.lerp(
            theme.colorScheme.primary,
            theme.colorScheme.error,
            progress,
          )!,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '\$${expenses.toStringAsFixed(0)}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'of \$${budget.toStringAsFixed(0)}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ArcBudgetPainter extends CustomPainter {
  const ArcBudgetPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = math.min(size.width, size.height) * 0.08;
    final rect = Rect.fromLTWH(
      stroke,
      stroke,
      size.width - stroke * 2,
      size.height * 1.65,
    );
    final start = math.pi;
    const sweep = math.pi;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = trackColor;
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = progressColor;

    canvas.drawArc(rect, start, sweep, false, track);
    canvas.drawArc(
      rect,
      start,
      sweep * progress.clamp(0, 1).toDouble(),
      false,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant ArcBudgetPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
