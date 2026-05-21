import 'dart:math' as math;

import 'package:flutter/material.dart';

class ParticleBurst extends StatefulWidget {
  const ParticleBurst({required this.trigger, super.key});

  final int trigger;

  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<ParticleBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 640),
    );
  }

  @override
  void didUpdateWidget(covariant ParticleBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger) {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: ParticleBurstPainter(
              progress: Curves.easeOut.transform(_controller.value),
              color: Theme.of(context).colorScheme.primary,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ParticleBurstPainter extends CustomPainter {
  const ParticleBurstPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) {
      return;
    }
    final origin = Offset(size.width - 56, size.height - 76);
    final paint = Paint()..color = color.withValues(alpha: 1 - progress);
    for (var i = 0; i < 18; i++) {
      final angle = (math.pi * 2 / 18) * i;
      final radius = 8 + 54 * progress;
      final position =
          origin + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawCircle(position, 2.5 + (1 - progress) * 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticleBurstPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
