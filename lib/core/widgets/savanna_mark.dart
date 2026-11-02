import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// A sun on the savanna horizon with two fibre lines running beneath it.
/// Placeholder mark until the official logo files are supplied.
class SavannaMark extends StatelessWidget {
  const SavannaMark({super.key, this.size = 36, this.lineColor});

  final double size;
  final Color? lineColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _MarkPainter(sun: context.sf.fibreLight, line: lineColor ?? context.sf.ink),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter({required this.sun, required this.line});

  final List<Color> sun;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final horizon = s * 0.58;
    final sunRect = Rect.fromCircle(center: Offset(s / 2, horizon), radius: s * 0.32);

    canvas.drawArc(
      sunRect,
      3.14159,
      3.14159,
      true,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: sun,
        ).createShader(sunRect),
    );

    final stroke = Paint()
      ..color = line
      ..strokeWidth = s * 0.07
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(s * 0.06, horizon), Offset(s * 0.94, horizon), stroke);

    final thin = Paint()
      ..color = line.withValues(alpha: 0.55)
      ..strokeWidth = s * 0.04
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(s * 0.2, horizon + s * 0.16), Offset(s * 0.8, horizon + s * 0.16), thin);
    canvas.drawLine(Offset(s * 0.34, horizon + s * 0.3), Offset(s * 0.66, horizon + s * 0.3), thin);
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.line != line;
}

class SavannaWordmark extends StatelessWidget {
  const SavannaWordmark({super.key, this.color, this.size = 32});

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.sf.ink;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SavannaMark(size: size, lineColor: c),
        const Gap(Insets.sm + 2),
        Text(
          'savanna fibre',
          style: GoogleFonts.sora(fontSize: size * 0.56, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: c),
        ),
      ],
    );
  }
}
