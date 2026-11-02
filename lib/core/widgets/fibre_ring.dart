import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Days-left gauge drawn as a strand of fibre with light travelling through
/// it. The glowing tip marks how far through the plan the customer is.
class FibreRing extends StatelessWidget {
  const FibreRing({
    super.key,
    required this.progress,
    required this.colors,
    required this.trackColor,
    this.size = 120,
    this.stroke = 10,
    this.ticks = 30,
    this.child,
  });

  /// 0 to 1.
  final double progress;
  final List<Color> colors;
  final Color trackColor;
  final double size;
  final double stroke;

  /// One faint notch per day of the plan.
  final int ticks;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(progress: value, stroke: stroke, colors: colors, trackColor: trackColor, ticks: ticks),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.stroke,
    required this.colors,
    required this.trackColor,
    required this.ticks,
  });

  final double progress;
  final double stroke;
  final List<Color> colors;
  final Color trackColor;
  final int ticks;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = trackColor,
    );

    // Day notches inside the track.
    final tickPaint = Paint()..color = trackColor.withValues(alpha: (trackColor.a * 2.2).clamp(0.0, 1.0));
    final tickRadius = radius - stroke - 3;
    for (var i = 0; i < ticks; i++) {
      final a = -math.pi / 2 + (2 * math.pi * i / ticks);
      canvas.drawCircle(center + Offset(math.cos(a), math.sin(a)) * tickRadius, 1.1, tickPaint);
    }

    if (progress <= 0) return;

    // Offset the gradient by the round cap so the start of the arc
    // doesn't pick up the wrap-around colour.
    final capAngle = (stroke / 2) / radius;
    final sweep = 2 * math.pi * progress;
    final shader = SweepGradient(
      startAngle: 0,
      endAngle: sweep + capAngle * 2,
      colors: colors,
      transform: GradientRotation(-math.pi / 2 - capAngle),
    ).createShader(rect);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = shader,
    );

    // Glowing tip.
    final tipAngle = -math.pi / 2 + sweep;
    final tip = center + Offset(math.cos(tipAngle), math.sin(tipAngle)) * radius;
    canvas.drawCircle(
      tip,
      stroke * 1.15,
      Paint()
        ..color = colors.last.withValues(alpha: 0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke * 0.9),
    );
    canvas.drawCircle(tip, stroke * 0.3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.colors != colors || old.trackColor != trackColor;
}
