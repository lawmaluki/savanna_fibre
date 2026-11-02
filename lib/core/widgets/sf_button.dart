import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';

enum SfButtonVariant { primary, secondary, ghost, danger }

class SfButton extends StatelessWidget {
  const SfButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = SfButtonVariant.primary,
    this.loading = false,
    this.expand = true,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final SfButtonVariant variant;
  final bool loading;

  /// Fill the available width. Set to false inside a Row.
  final bool expand;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    final (Color bg, Color fg) = switch (variant) {
      SfButtonVariant.primary => (p.accent, p.onAccent),
      SfButtonVariant.secondary => (p.hero, p.heroInk),
      SfButtonVariant.ghost => (Colors.transparent, p.ink),
      SfButtonVariant.danger => (p.dangerSoft, p.danger),
    };
    final height = compact ? 42.0 : 54.0;

    final content = loading
        ? SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.2, color: fg))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: compact ? 18 : 20, color: fg), const Gap(Insets.sm)],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (compact ? context.text.titleSmall : context.text.labelLarge)!.copyWith(color: fg),
                ),
              ),
            ],
          );

    final disabledBg = loading || variant == SfButtonVariant.ghost ? bg : bg.withValues(alpha: 0.4);

    return Semantics(
      button: true,
      enabled: onPressed != null && !loading,
      child: SfPressable(
        enabled: onPressed != null && !loading,
        child: FilledButton(
          onPressed: loading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            disabledBackgroundColor: disabledBg,
            disabledForegroundColor: fg.withValues(alpha: 0.55),
            elevation: 0,
            minimumSize: Size(expand ? double.infinity : 0, height),
            padding: EdgeInsets.symmetric(horizontal: compact ? Insets.lg : 22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(compact ? 12 : 16)),
            side: variant == SfButtonVariant.ghost ? BorderSide(color: p.line, width: 1.2) : null,
          ),
          child: AnimatedSwitcher(duration: Motion.fast, child: content),
        ),
      ),
    );
  }
}
