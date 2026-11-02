import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/widgets/widgets.dart';

/// Stylised location preview. Swap for google_maps_flutter or a static map
/// image when the backend is connected; the raw coordinates stay secondary.
class MapPreview extends StatelessWidget {
  const MapPreview({super.key, required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    return Semantics(
      label: 'Installation location map',
      button: true,
      child: GestureDetector(
        onTap: () => showSfSnack(context, 'Opens in Maps once location services are connected'),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Radii.md),
          child: SizedBox(
            height: 140,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MapPainter(ground: p.surfaceAlt, road: p.surface, block: p.line),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: p.accent.withValues(alpha: 0.22), shape: BoxShape.circle),
                        child: Icon(PhosphorIconsFill.mapPin, color: p.accentDeep, size: 30),
                      ),
                      const Gap(18),
                    ],
                  ),
                ),
                Positioned(
                  left: Insets.sm,
                  bottom: Insets.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(Radii.pill)),
                    child: Text(
                      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}',
                      style: context.text.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({required this.ground, required this.road, required this.block});

  final Color ground;
  final Color road;
  final Color block;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = ground);

    final blockPaint = Paint()..color = block.withValues(alpha: 0.6);
    final blocks = [
      Rect.fromLTWH(w * 0.05, h * 0.08, w * 0.22, h * 0.28),
      Rect.fromLTWH(w * 0.62, h * 0.06, w * 0.3, h * 0.22),
      Rect.fromLTWH(w * 0.08, h * 0.62, w * 0.18, h * 0.3),
      Rect.fromLTWH(w * 0.7, h * 0.6, w * 0.24, h * 0.32),
      Rect.fromLTWH(w * 0.36, h * 0.72, w * 0.14, h * 0.2),
    ];
    for (final b in blocks) {
      canvas.drawRRect(RRect.fromRectAndRadius(b, const Radius.circular(6)), blockPaint);
    }

    final major = Paint()
      ..color = road
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final minor = Paint()
      ..color = road
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      Path()
        ..moveTo(-10, h * 0.48)
        ..quadraticBezierTo(w * 0.5, h * 0.38, w + 10, h * 0.52),
      major,
    );
    canvas.drawLine(Offset(w * 0.32, -10), Offset(w * 0.56, h + 10), minor);
    canvas.drawLine(Offset(w * 0.58, h * 0.48), Offset(w * 0.66, h + 10), minor);
  }

  @override
  bool shouldRepaint(_MapPainter old) => old.ground != ground || old.road != road;
}
