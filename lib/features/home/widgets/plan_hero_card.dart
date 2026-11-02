import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/widgets/widgets.dart';
import '../../../data/models/plan.dart';

/// The one bold element on Home: a night-sky card with fibre strands, and a
/// ring that shows how much of the plan is left.
class PlanHeroCard extends StatelessWidget {
  const PlanHeroCard({super.key, required this.connection});

  final Connection connection;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    final t = context.text;
    final now = DateTime.now();
    final status = connection.status(now);
    final days = connection.daysLeft(now);
    final expired = status == ConnectionStatus.expired;
    final progress = expired ? 0.0 : days / connection.plan.validityDays;

    final (String statusLabel, SfTone tone) = switch (status) {
      ConnectionStatus.active => ('Active', SfTone.success),
      ConnectionStatus.expiringSoon => ('Ends soon', SfTone.warning),
      ConnectionStatus.expired => ('Expired', SfTone.danger),
    };

    return Container(
      decoration: BoxDecoration(color: p.hero, borderRadius: BorderRadius.circular(Radii.xl)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: FibreStrands(color: p.accent, animate: !expired),
          ),
          Padding(
            padding: const EdgeInsets.all(Insets.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        connection.id,
                        style: t.labelMedium!.copyWith(color: p.heroMuted, letterSpacing: 0.3),
                      ),
                    ),
                    SfStatusChip(label: statusLabel, tone: tone, onDark: true),
                  ],
                ),
                const Gap(Insets.lg + 2),
                Row(
                  children: [
                    Semantics(
                      label: expired ? 'Plan expired' : '$days days left on your plan',
                      excludeSemantics: true,
                      child: FibreRing(
                        progress: progress,
                        size: 118,
                        stroke: 9,
                        ticks: connection.plan.validityDays,
                        colors: p.fibreLight,
                        trackColor: p.heroInk.withValues(alpha: 0.08),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$days', style: t.displaySmall!.copyWith(color: p.heroInk, height: 1)),
                            const Gap(2),
                            Text(
                              days == 1 ? 'day left' : 'days left',
                              style: t.labelSmall!.copyWith(color: p.heroMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(Insets.xl),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${connection.plan.name} plan', style: t.headlineSmall!.copyWith(color: p.heroInk)),
                          const Gap(Insets.md),
                          _HeroStat(icon: PhosphorIconsRegular.gauge, label: '${connection.plan.speedMbps} Mbps'),
                          const Gap(Insets.sm),
                          const _HeroStat(icon: PhosphorIconsRegular.infinity, label: 'Unlimited data'),
                          const Gap(Insets.sm),
                          _HeroStat(
                            icon: PhosphorIconsRegular.calendarBlank,
                            label: expired
                                ? 'Ended ${fmtDate(connection.expiresAt)}'
                                : 'Until ${fmtDate(connection.expiresAt)}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(Insets.xl),
                if (expired) ...[
                  Text(
                    'Your internet is paused. Renew to get back online right away.',
                    style: t.bodySmall!.copyWith(color: p.heroMuted),
                  ),
                  const Gap(Insets.md),
                ],
                SfButton(
                  label: expired ? 'Renew now' : 'Extend or upgrade',
                  icon: PhosphorIconsBold.arrowsClockwise,
                  onPressed: () => context.push('/renew'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    return Row(
      children: [
        Icon(icon, size: 16, color: p.heroMuted),
        const Gap(Insets.sm),
        Flexible(
          child: Text(label, style: context.text.bodyMedium!.copyWith(color: p.heroInk.withValues(alpha: 0.9))),
        ),
      ],
    );
  }
}
