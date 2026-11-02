import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum SfTone { neutral, success, warning, danger, accent }

class SfStatusChip extends StatelessWidget {
  const SfStatusChip({
    super.key,
    required this.label,
    this.tone = SfTone.neutral,
    this.dot = true,
    this.onDark = false,
  });

  final String label;
  final SfTone tone;
  final bool dot;

  /// Use on the dark plan card and other night-coloured surfaces.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    final (Color bg, Color fg) = onDark
        ? switch (tone) {
            SfTone.success => (const Color(0xFF63D69B).withValues(alpha: 0.16), const Color(0xFF7BE3AE)),
            SfTone.warning => (const Color(0xFFF5C451).withValues(alpha: 0.16), const Color(0xFFF7CD68)),
            SfTone.danger => (const Color(0xFFFF7A70).withValues(alpha: 0.16), const Color(0xFFFF8F86)),
            SfTone.accent => (p.accent.withValues(alpha: 0.18), const Color(0xFFFFB25C)),
            SfTone.neutral => (p.heroInk.withValues(alpha: 0.10), p.heroMuted),
          }
        : switch (tone) {
            SfTone.success => (p.successSoft, p.success),
            SfTone.warning => (p.warningSoft, p.warning),
            SfTone.danger => (p.dangerSoft, p.danger),
            SfTone.accent => (p.accentSoft, p.accentDeep),
            SfTone.neutral => (p.surfaceAlt, p.inkMuted),
          };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Radii.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const Gap(6),
          ],
          Text(
            label,
            style: context.text.labelMedium!.copyWith(color: fg, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
