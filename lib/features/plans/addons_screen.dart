import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/widgets/widgets.dart';
import '../../data/models/plan.dart';
import '../../state/account_providers.dart';
import '../payments/payment_sheet.dart';

class AddonsScreen extends ConsumerWidget {
  const AddonsScreen({super.key});

  static IconData _iconFor(String id) => switch (id) {
    'static_ip' => PhosphorIconsRegular.globe,
    'mesh' => PhosphorIconsRegular.wifiHigh,
    'boost' => PhosphorIconsRegular.lightning,
    'router_upgrade' => PhosphorIconsRegular.wifiHigh,
    _ => PhosphorIconsRegular.puzzlePiece,
  };

  Future<void> _buy(BuildContext context, WidgetRef ref, Addon addon) async {
    final paid = await showPaymentSheet(
      context,
      title: 'Add ${addon.name}',
      amount: addon.priceKes,
      onPay: (method) => ref.read(activeAddonsProvider.notifier).purchase(addon, method),
    );
    if (paid == true && context.mounted) {
      await showSuccessSheet(context, title: '${addon.name} added', message: addon.confirmation);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.sf;
    final addons = ref.watch(addonsProvider);
    final active = ref.watch(activeAddonsProvider);

    return Scaffold(
      appBar: const SfAppBar(title: 'Add-ons'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Insets.page, Insets.sm, Insets.page, Insets.xxl),
        children: [
          Text(
            'Extras for your connection. Monthly add-ons renew with your plan.',
            style: context.text.bodyMedium!.copyWith(color: p.inkMuted),
          ),
          const Gap(Insets.lg),
          for (final addon in addons)
            Padding(
              padding: const EdgeInsets.only(bottom: Insets.md),
              child: SfCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SfIconBox(icon: _iconFor(addon.id)),
                        const Gap(Insets.md + 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(addon.name, style: context.text.titleMedium),
                              const Gap(Insets.xs),
                              Text(addon.description, style: context.text.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Gap(Insets.lg),
                    Row(
                      children: [
                        Text(kes(addon.priceKes), style: context.text.titleMedium),
                        Text(
                          addon.billing == AddonBilling.monthly ? ' a month' : ' once',
                          style: context.text.bodySmall,
                        ),
                        const Spacer(),
                        if (active.contains(addon.id))
                          const SfStatusChip(label: 'Added', tone: SfTone.success)
                        else
                          SfButton(
                            label: 'Add',
                            icon: PhosphorIconsBold.plus,
                            compact: true,
                            expand: false,
                            variant: SfButtonVariant.secondary,
                            onPressed: () => _buy(context, ref, addon),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ].staggered(),
      ),
    );
  }
}
