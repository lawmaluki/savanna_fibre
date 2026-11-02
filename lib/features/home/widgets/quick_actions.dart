import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/widgets/widgets.dart';

/// Two-by-two grid of shortcut tiles.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  static const _actions = <(IconData, String, String, String)>[
    (PhosphorIconsFill.receipt, 'Billing', 'Invoices & payments', '/billing'),
    (PhosphorIconsFill.headset, 'Support', 'Tickets & reports', '/support'),
    (PhosphorIconsFill.puzzlePiece, 'Add-ons', 'Boost your plan', '/addons'),
    (PhosphorIconsFill.lifebuoy, 'Get help', 'FAQs & guides', '/help'),
  ];

  @override
  Widget build(BuildContext context) {
    Widget tile(int i) {
      final (icon, title, subtitle, route) = _actions[i];
      return Expanded(
        child: _ActionTile(icon: icon, title: title, subtitle: subtitle, onTap: () => context.push(route)),
      );
    }

    return Column(
      children: [
        Row(children: [tile(0), const Gap(Insets.md), tile(1)]),
        const Gap(Insets.md),
        Row(children: [tile(2), const Gap(Insets.md), tile(3)]),
      ],
    );
  }
}

class _ActionTile extends StatefulWidget {
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    final t = context.text;
    return Semantics(
      button: true,
      label: '${widget.title}. ${widget.subtitle}',
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(Insets.lg),
            decoration: BoxDecoration(
              color: _pressed ? p.accentSoft : p.surface,
              borderRadius: BorderRadius.circular(Radii.lg),
              border: Border.all(color: _pressed ? p.accent.withValues(alpha: 0.4) : p.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SfIconBox(icon: widget.icon, size: 42, iconSize: 21, radius: Radii.md),
                    const Spacer(),
                    Icon(PhosphorIconsBold.arrowUpRight, size: 16, color: p.inkMuted),
                  ],
                ),
                const Gap(Insets.lg),
                Text(widget.title, style: t.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const Gap(2),
                Text(
                  widget.subtitle,
                  style: t.bodySmall!.copyWith(color: p.inkMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
