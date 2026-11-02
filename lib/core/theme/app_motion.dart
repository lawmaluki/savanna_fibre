import 'dart:math' as math;

import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'app_spacing.dart';

/// Motion tokens. Everything moves on the same few durations and curves so
/// the app feels like one piece, and everything stands still when the system
/// asks for reduced motion.
abstract final class Motion {
  static const fast = Duration(milliseconds: 140);
  static const medium = Duration(milliseconds: 260);
  static const slow = Duration(milliseconds: 420);

  /// Delay between items in a staggered entrance.
  static const stagger = Duration(milliseconds: 45);

  static const standard = Curves.easeOutCubic;
  static const settle = Curves.easeOutBack;

  /// Page transitions: fade-forwards on Android and desktop, native swipe
  /// back on Apple platforms.
  static const pageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    },
  );

  static bool reduced(BuildContext context) => MediaQuery.disableAnimationsOf(context);
}

extension StaggeredEntrance on List<Widget> {
  /// Fades and lifts each item in, one after another. Spacers don't use up a
  /// step, and the delay is capped so items far down a long list don't wait
  /// when they're scrolled into view.
  List<Widget> staggered({int maxSteps = 8}) {
    var step = 0;
    return [
      for (final child in this)
        if (child is Gap || child is SizedBox || child is Spacer)
          child
        else
          _Entrance(delay: Motion.stagger * math.min(step++, maxSteps), child: child),
    ];
  }
}

class _Entrance extends StatelessWidget {
  const _Entrance({required this.delay, required this.child});

  final Duration delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return child;
    return child
        .animate(delay: delay)
        .fadeIn(duration: Motion.slow, curve: Curves.easeOut)
        .slideY(begin: 0.06, end: 0, duration: Motion.slow, curve: Motion.standard);
  }
}

/// Validation message that slides open under a field. It is always in the
/// tree, so showing it doesn't shift the widgets around it.
class SfInlineError extends StatelessWidget {
  const SfInlineError(this.message, {super.key, required this.color, required this.style});

  final String? message;
  final Color color;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Motion.medium,
      curve: Motion.standard,
      alignment: Alignment.topLeft,
      child: AnimatedSwitcher(
        duration: Motion.medium,
        child: message == null
            ? const SizedBox(width: double.infinity)
            : Padding(
                key: ValueKey(message),
                padding: const EdgeInsets.only(top: Insets.sm),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(message!, style: style.copyWith(color: color)),
                ),
              ),
      ),
    );
  }
}

/// Gives anything tappable a soft press-in. It only listens to the pointer,
/// so the child's own InkWell or button still handles the tap, and a drag
/// that turns into a scroll releases the press.
class SfPressable extends StatefulWidget {
  const SfPressable({super.key, required this.child, this.enabled = true, this.scale = 0.97});

  final Widget child;
  final bool enabled;
  final double scale;

  @override
  State<SfPressable> createState() => _SfPressableState();
}

class _SfPressableState extends State<SfPressable> {
  bool _pressed = false;
  Offset? _origin;

  void _set(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || Motion.reduced(context)) return widget.child;
    return Listener(
      onPointerDown: (e) {
        _origin = e.position;
        _set(true);
      },
      onPointerMove: (e) {
        if (_origin != null && (e.position - _origin!).distance > 8) _set(false);
      },
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: _pressed ? Motion.fast : Motion.medium,
        curve: _pressed ? Curves.easeOut : Motion.settle,
        child: widget.child,
      ),
    );
  }
}
