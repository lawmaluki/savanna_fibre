import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';

/// Flat surface with a hairline border. No drop shadows: depth comes from the
/// dark plan card and nav, not from stacking shadows on every card.
class SfCard extends StatelessWidget {
  const SfCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Insets.lg),
    this.onTap,
    this.color,
    this.borderColor,
    this.radius = Radii.lg,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    return SfPressable(
      enabled: onTap != null,
      scale: 0.98,
      child: Material(
        color: color ?? p.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: borderColor ?? p.line),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Rounded square holding an icon.
class SfIconBox extends StatelessWidget {
  const SfIconBox({
    super.key,
    required this.icon,
    this.size = 44,
    this.iconSize = 22,
    this.background,
    this.foreground,
    this.radius = Radii.md,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color? background;
  final Color? foreground;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background ?? p.accentSoft, borderRadius: BorderRadius.circular(radius)),
      child: Icon(icon, size: iconSize, color: foreground ?? p.accentDeep),
    );
  }
}
