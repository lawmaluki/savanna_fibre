import 'package:flutter/material.dart';

/// Faint fibre strands sweeping across a dark surface, with a pulse of light
/// travelling along two of them. This is the app's one ambient animation;
/// it stops when [animate] is false or the OS asks for reduced motion.
class FibreStrands extends StatefulWidget {
  const FibreStrands({super.key, required this.color, this.animate = true});

  final Color color;
  final bool animate;

  @override
  State<FibreStrands> createState() => _FibreStrandsState();
}

class _FibreStrandsState extends State<FibreStrands> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 6));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(FibreStrands oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (widget.animate && !reduceMotion) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _StrandsPainter(color: widget.color, animation: _controller, showPulse: widget.animate),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _StrandsPainter extends CustomPainter {
  _StrandsPainter({required this.color, required this.animation, required this.showPulse}) : super(repaint: animation);

  final Color color;
  final Animation<double> animation;
  final bool showPulse;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const count = 4;

    for (var i = 0; i < count; i++) {
      final path = Path()
        ..moveTo(w * 0.30, h + 10)
        ..cubicTo(
          w * (0.55 + i * 0.04),
          h * (0.92 - i * 0.05),
          w * (0.70 + i * 0.02),
          h * (0.30 + i * 0.07),
          w + 12,
          h * (0.10 + i * 0.09),
        );

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = color.withValues(alpha: 0.10 + i * 0.04),
      );

      // Light pulses on strands 1 and 3 only.
      if (!showPulse || i.isEven) continue;
      final metric = path.computeMetrics().first;
      final t = (animation.value + i * 0.37) % 1.0;
      final len = metric.length;
      final segment = metric.extractPath(len * t, len * t + len * 0.14);

      canvas.drawPath(
        segment,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawPath(
        segment,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round
          ..color = Color.lerp(color, Colors.white, 0.45)!,
      );
    }
  }

  @override
  bool shouldRepaint(_StrandsPainter old) => old.color != color || old.showPulse != showPulse;
}
