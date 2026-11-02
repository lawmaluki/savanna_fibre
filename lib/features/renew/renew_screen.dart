import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/widgets/widgets.dart';
import '../../data/models/plan.dart';
import '../../state/account_providers.dart';
import '../payments/payment_sheet.dart';

class RenewScreen extends ConsumerStatefulWidget {
  const RenewScreen({super.key});

  @override
  ConsumerState<RenewScreen> createState() => _RenewScreenState();
}

class _RenewScreenState extends ConsumerState<RenewScreen> {
  String? _selectedId;

  Future<void> _checkout(Plan plan) async {
    final paid = await showPaymentSheet(
      context,
      title: 'Renew ${plan.name} plan',
      amount: plan.priceKes,
      onPay: (method) => ref.read(connectionProvider.notifier).renew(plan, method),
    );
    if (paid != true || !mounted) return;
    final connection = ref.read(connectionProvider);
    await showSuccessSheet(
      context,
      title: "You're back online",
      message: 'Your ${plan.name} plan is active until ${fmtDate(connection.expiresAt)}.',
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    final connection = ref.watch(connectionProvider);
    final plans = ref.watch(renewablePlansProvider);

    _selectedId ??= plans.any((plan) => plan.id == connection.plan.id)
        ? connection.plan.id
        : plans.firstWhere((plan) => plan.popular, orElse: () => plans.first).id;
    final selected = plans.firstWhere((plan) => plan.id == _selectedId);

    return Scaffold(
      appBar: const SfAppBar(title: 'Renew plan'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Insets.page, Insets.sm, Insets.page, Insets.xxl),
        children: [
          _ConnectionCard(connection: connection),
          const Gap(Insets.xxl + 4),
          const SfSectionHeader(title: 'Choose a plan'),
          const Gap(Insets.xs),
          Text(
            'Every plan includes unlimited data. Your new speed starts as soon as you pay.',
            style: context.text.bodyMedium!.copyWith(color: p.inkMuted),
          ),
          const Gap(Insets.lg),
          for (final plan in plans)
            Padding(
              padding: const EdgeInsets.only(bottom: Insets.sm + 2),
              child: _PlanOption(
                plan: plan,
                selected: plan.id == _selectedId,
                current: plan.id == connection.plan.id,
                onTap: () => setState(() => _selectedId = plan.id),
              ),
            ),
        ].staggered(),
      ),
      bottomNavigationBar: _CheckoutBar(
        amountLabel: kes(selected.priceKes),
        detail: '${selected.name}, ${selected.validityDays} days',
        onContinue: () => _checkout(selected),
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({required this.connection});

  final Connection connection;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    final expired = connection.status(DateTime.now()) == ConnectionStatus.expired;
    return SfCard(
      onTap: () => showSfSheet<void>(
        context,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your connections', style: sheetContext.text.headlineSmall),
            const Gap(Insets.lg),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const SfIconBox(icon: PhosphorIconsRegular.wifiHigh, size: 40, iconSize: 20),
              title: Text(connection.id, style: sheetContext.text.titleSmall),
              subtitle: Text('${connection.plan.name} plan', style: sheetContext.text.bodySmall),
              trailing: Icon(PhosphorIconsFill.checkCircle, color: p.accent),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
      child: Row(
        children: [
          const SfIconBox(icon: PhosphorIconsRegular.wifiHigh),
          const Gap(Insets.md + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Connection', style: context.text.labelMedium),
                const Gap(2),
                Text(connection.id, style: context.text.titleMedium),
                const Gap(2),
                Text(
                  expired
                      ? '${connection.plan.name} plan ended ${fmtDate(connection.expiresAt)}'
                      : '${connection.plan.name} plan until ${fmtDate(connection.expiresAt)}',
                  style: context.text.bodySmall!.copyWith(color: expired ? p.danger : p.inkMuted),
                ),
              ],
            ),
          ),
          Icon(PhosphorIconsRegular.caretDown, color: p.inkMuted, size: 18),
        ],
      ),
    );
  }
}

class _PlanOption extends StatelessWidget {
  const _PlanOption({required this.plan, required this.selected, required this.current, required this.onTap});

  final Plan plan;
  final bool selected;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    final t = context.text;
    return Semantics(
      selected: selected,
      button: true,
      label: '${plan.name}, ${plan.speedMbps} megabits, ${kes(plan.priceKes)} for ${plan.validityDays} days',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(color: selected ? p.accent : p.line, width: selected ? 2 : 1),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(Radii.lg),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(selected ? 15 : 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 62,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${plan.speedMbps}', style: t.headlineLarge!.copyWith(height: 1)),
                        const Gap(2),
                        Text('Mbps', style: t.labelSmall),
                      ],
                    ),
                  ),
                  const Gap(Insets.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: Insets.sm,
                          runSpacing: Insets.xs,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(plan.name, style: t.titleMedium),
                            if (current) const SfStatusChip(label: 'Current', dot: false),
                            if (plan.popular && !current)
                              const SfStatusChip(label: 'Popular', tone: SfTone.accent, dot: false),
                          ],
                        ),
                        const Gap(Insets.xs),
                        Text(plan.tagline, style: t.bodySmall),
                      ],
                    ),
                  ),
                  const Gap(Insets.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(kes(plan.priceKes), style: t.titleMedium),
                      const Gap(2),
                      Text('${plan.validityDays} days', style: t.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.amountLabel, required this.detail, required this.onContinue});

  final String amountLabel;
  final String detail;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Insets.page, Insets.md, Insets.page, Insets.md),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(amountLabel, style: context.text.titleLarge),
                  Text(detail, style: context.text.bodySmall),
                ],
              ),
              const Gap(Insets.lg),
              Expanded(
                child: SfButton(label: 'Continue', onPressed: onContinue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
