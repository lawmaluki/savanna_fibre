import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/widgets/widgets.dart';
import '../../../data/models/customer.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    final t = context.text;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.heroRaised, p.hero],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -55,
            top: -65,
            child: ExcludeSemantics(
              child: Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: p.heroInk.withValues(alpha: 0.06),
                    width: 32,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Insets.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: p.accent.withValues(alpha: 0.4),
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: p.accent,
                        child: Text(
                          customer.initials,
                          style: t.headlineSmall!.copyWith(color: p.onAccent),
                        ),
                      ),
                    ),
                    const Gap(Insets.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good to have you here',
                            style: t.bodySmall!.copyWith(color: p.heroMuted),
                          ),
                          const Gap(6),
                          Text(
                            customer.name,
                            style: t.headlineSmall!.copyWith(color: p.heroInk),
                          ),
                          const Gap(Insets.md),
                          Wrap(
                            spacing: Insets.sm,
                            runSpacing: Insets.sm,
                            children: [
                              _HeaderBadge(
                                label: customer.isActive
                                    ? 'Active account'
                                    : 'Inactive account',
                                color: customer.isActive
                                    ? const Color(0xFF83E0B1)
                                    : const Color(0xFFFFA59E),
                                showDot: true,
                              ),
                              _HeaderBadge(
                                label: '${customer.category} member',
                                color: p.heroInk,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(Insets.xxl),
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    Insets.lg,
                    Insets.md,
                    Insets.sm,
                    Insets.md,
                  ),
                  decoration: BoxDecoration(
                    color: p.heroInk.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(Radii.md),
                    border: Border.all(
                      color: p.heroInk.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account number',
                              style: t.bodySmall!.copyWith(color: p.heroMuted),
                            ),
                            const Gap(4),
                            Text(
                              customer.accountNumber,
                              style: t.titleLarge!.copyWith(
                                color: p.heroInk,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copy account number',
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: customer.accountNumber),
                          );
                          if (context.mounted) {
                            showSfSnack(context, 'Account number copied');
                          }
                        },
                        icon: Icon(
                          PhosphorIconsRegular.copy,
                          size: 20,
                          color: p.heroInk,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(Insets.xl),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _AccountDetail(
                        label: 'Billing type',
                        value: customer.customerType,
                      ),
                    ),
                    const Gap(Insets.lg),
                    Expanded(
                      child: _AccountDetail(
                        label: 'Customer since',
                        value: fmtDate(customer.activatedAt),
                      ),
                    ),
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

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({
    required this.label,
    required this.color,
    this.showDot = false,
  });

  final String label;
  final Color color;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const Gap(6),
          ],
          Flexible(
            child: Text(
              label,
              style: context.text.labelSmall!.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountDetail extends StatelessWidget {
  const _AccountDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.text.bodySmall!.copyWith(color: context.sf.heroMuted),
        ),
        const Gap(4),
        Text(
          value,
          style: context.text.titleSmall!.copyWith(color: context.sf.heroInk),
        ),
      ],
    );
  }
}
