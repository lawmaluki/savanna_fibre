import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import 'sf_button.dart';
import 'sf_card.dart';

class SfSectionHeader extends StatelessWidget {
  const SfSectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: context.text.titleLarge)),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(foregroundColor: context.sf.accentDeep),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

/// App bar with a round back button, used on every pushed screen.
class SfAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SfAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    final canPop = Navigator.of(context).canPop();
    return AppBar(
      toolbarHeight: 64,
      leadingWidth: canPop ? 68 : null,
      automaticallyImplyLeading: false,
      leading: canPop
          ? Padding(
              padding: const EdgeInsets.only(left: Insets.page),
              child: Center(
                child: Material(
                  color: p.surface,
                  shape: CircleBorder(side: BorderSide(color: p.line)),
                  child: IconButton(
                    tooltip: 'Back',
                    icon: Icon(PhosphorIconsBold.caretLeft, size: 18, color: p.ink),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ),
            )
          : null,
      title: Text(title),
      actions: [...?actions, const Gap(Insets.sm)],
    );
  }
}

/// A titled group of rows inside one card, like iOS settings.
class SfGroup extends StatelessWidget {
  const SfGroup({super.key, required this.title, required this.children, this.actionLabel, this.onAction});

  final String title;
  final List<Widget> children;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i < children.length - 1) rows.add(const Divider());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: Insets.xs, bottom: Insets.sm),
          child: Row(
            children: [
              Expanded(
                child: Text(title, style: context.text.labelLarge!.copyWith(color: context.sf.inkMuted)),
              ),
              if (actionLabel != null)
                GestureDetector(
                  onTap: onAction,
                  child: Text(actionLabel!, style: context.text.labelLarge!.copyWith(color: context.sf.accentDeep)),
                ),
            ],
          ),
        ),
        SfCard(
          padding: const EdgeInsets.symmetric(horizontal: Insets.lg),
          child: Column(children: rows),
        ),
      ],
    );
  }
}

class SfInfoRow extends StatelessWidget {
  const SfInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.placeholder = false,
    this.emphasize = false,
    this.trailing,
  });

  final String label;
  final String value;

  /// Value is a prompt ("Not added") rather than real data.
  final bool placeholder;
  final bool emphasize;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    final t = context.text;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: emphasize ? t.titleSmall : t.bodyMedium!.copyWith(color: p.inkMuted)),
          ),
          const Gap(Insets.lg),
          Flexible(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: (emphasize ? t.titleMedium : t.titleSmall)!.copyWith(
                color: placeholder ? p.inkMuted : p.ink,
                fontWeight: placeholder ? FontWeight.w400 : null,
              ),
            ),
          ),
          if (trailing != null) ...[const Gap(Insets.sm), trailing!],
        ],
      ),
    );
  }
}

class SfEmptyState extends StatelessWidget {
  const SfEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.xxxl, horizontal: Insets.lg),
      child: Column(
        children: [
          SfIconBox(icon: icon, size: 64, iconSize: 28, radius: 22, background: p.surfaceAlt, foreground: p.inkMuted),
          const Gap(Insets.lg),
          Text(title, style: context.text.titleLarge, textAlign: TextAlign.center),
          const Gap(6),
          Text(
            message,
            style: context.text.bodyMedium!.copyWith(color: p.inkMuted),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null) ...[
            const Gap(Insets.xl),
            SfButton(label: actionLabel!, onPressed: onAction, expand: false, compact: true),
          ],
        ],
      ),
    );
  }
}

/// Two-option segmented switch.
class SfSegmented extends StatelessWidget {
  const SfSegmented({super.key, required this.labels, required this.index, required this.onChanged});

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(Radii.md)),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                selected: i == index,
                button: true,
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == index ? p.surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(Radii.sm),
                      border: i == index ? Border.all(color: p.line) : null,
                    ),
                    child: Text(
                      labels[i],
                      style: context.text.titleSmall!.copyWith(color: i == index ? p.ink : p.inkMuted),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Selectable pill used for filters, amounts and time slots.
class SfChoicePill extends StatelessWidget {
  const SfChoicePill({super.key, required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    return Semantics(
      selected: selected,
      button: true,
      child: SfPressable(
        scale: 0.95,
        child: AnimatedContainer(
          duration: Motion.medium,
          curve: Motion.standard,
          decoration: ShapeDecoration(
            color: selected ? p.hero : p.surface,
            shape: StadiumBorder(side: BorderSide(color: selected ? p.hero : p.line)),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Insets.lg, vertical: 10),
                child: AnimatedDefaultTextStyle(
                  duration: Motion.medium,
                  style: context.text.titleSmall!.copyWith(color: selected ? p.heroInk : p.ink),
                  child: Text(label),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
