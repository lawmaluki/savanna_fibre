import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/widgets/widgets.dart';
import '../../../state/account_providers.dart';

/// Light companion to the dark plan card: a warm glow in the corner, a large
/// balance, and a single top-up action.
class WalletCard extends ConsumerWidget {
  const WalletCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.sf;
    final t = context.text;
    final balance = ref.watch(walletProvider.select((w) => w.balance));
    final hidden = ref.watch(balanceHiddenProvider);
    final amountStyle = t.headlineLarge!.copyWith(fontWeight: FontWeight.w700, height: 1.1);

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(Radii.xl),
        border: Border.all(color: p.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: IgnorePointer(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [p.accent.withValues(alpha: 0.22), p.accent.withValues(alpha: 0)]),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Insets.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SfIconBox(icon: PhosphorIconsFill.wallet, size: 36, iconSize: 18, radius: Radii.sm),
                    const Gap(Insets.md),
                    Expanded(child: Text('Wallet', style: t.titleSmall)),
                    Material(
                      color: p.surface.withValues(alpha: 0.7),
                      shape: CircleBorder(side: BorderSide(color: p.line)),
                      child: IconButton(
                        tooltip: hidden ? 'Show balance' : 'Hide balance',
                        visualDensity: VisualDensity.compact,
                        onPressed: ref.read(balanceHiddenProvider.notifier).toggle,
                        icon: Icon(
                          hidden ? PhosphorIconsRegular.eyeSlash : PhosphorIconsRegular.eye,
                          color: p.inkMuted,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(Insets.lg),
                Text('Available balance', style: t.labelMedium!.copyWith(color: p.inkMuted)),
                const Gap(Insets.xs),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: FittedBox(
                    key: ValueKey(hidden),
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'KES ',
                            style: t.titleMedium!.copyWith(color: p.inkMuted),
                          ),
                          if (hidden)
                            TextSpan(text: '••••••', style: amountStyle)
                          else
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: _CountUp(value: balance, style: amountStyle),
                            ),
                        ],
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
                const Gap(Insets.lg),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Pays for renewals and add-ons instantly',
                        style: t.bodySmall!.copyWith(color: p.inkMuted),
                      ),
                    ),
                    const Gap(Insets.md),
                    _TopUpPill(onTap: () => context.push('/top-up')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Rolls the balance up from zero on first show, and from the old balance to
/// the new one after a top-up or payment.
class _CountUp extends StatelessWidget {
  const _CountUp({required this.value, required this.style});

  final num value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.toDouble()),
      duration: Motion.reduced(context) ? Duration.zero : const Duration(milliseconds: 900),
      curve: Motion.standard,
      builder: (context, v, _) => Text(kes(v, cents: true).substring(4), style: style),
    );
  }
}

class _TopUpPill extends StatelessWidget {
  const _TopUpPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    return Semantics(
      button: true,
      label: 'Top up wallet',
      excludeSemantics: true,
      child: SfPressable(
        scale: 0.94,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.pill),
            boxShadow: [BoxShadow(color: p.accent.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 4))],
          ),
          child: Material(
            color: p.accent,
            shape: const StadiumBorder(),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Insets.md, 10, Insets.lg, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(color: p.onAccent, shape: BoxShape.circle),
                      child: Icon(PhosphorIconsBold.plus, size: 13, color: p.accent),
                    ),
                    const Gap(Insets.sm),
                    Text('Top up', style: context.text.titleSmall!.copyWith(color: p.onAccent)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
