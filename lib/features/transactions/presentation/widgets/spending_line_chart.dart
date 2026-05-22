import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SpendingLineChart extends StatelessWidget {
  const SpendingLineChart({required this.values, super.key});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116,
      width: double.infinity,
      child: CustomPaint(
        painter: SpendingLineChartPainter(
          values: values,
          color: Theme.of(context).colorScheme.tertiary,
          gridColor: Theme.of(context).dividerColor,
        ),
      ),
    );
  }
}

class SpendingLineChartPainter extends CustomPainter {
  const SpendingLineChartPainter({
    required this.values,
    required this.color,
    required this.gridColor,
  });

  final List<double> values;
  final Color color;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = gridColor.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    if (values.isEmpty) {
      return;
    }
    final maxValue = values.fold<double>(
      0,
      (max, item) => item > max ? item : max,
    );
    final denominator = maxValue == 0 ? 1 : maxValue;
    final step = values.length == 1
        ? size.width
        : size.width / (values.length - 1);
    final path = Path();

    for (var i = 0; i < values.length; i++) {
      final x = step * i;
      final y = size.height - (values[i] / denominator * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final area = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 3
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant SpendingLineChartPainter oldDelegate) {
    return !listEquals(oldDelegate.values, values) ||
        oldDelegate.color != color ||
        oldDelegate.gridColor != gridColor;
  }
}
