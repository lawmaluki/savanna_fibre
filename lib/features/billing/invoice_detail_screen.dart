import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/widgets/widgets.dart';
import '../../data/models/billing.dart';
import '../../state/account_providers.dart';

class InvoiceDetailScreen extends ConsumerWidget {
  const InvoiceDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoice = ref.watch(invoicesProvider).where((i) => i.id == id).firstOrNull;
    final account = ref.watch(customerProvider.select((c) => c.accountNumber));

    if (invoice == null) {
      return const Scaffold(
        appBar: SfAppBar(title: 'Invoice'),
        body: SfEmptyState(
          icon: PhosphorIconsRegular.receipt,
          title: 'Invoice not found',
          message: 'It may have been replaced by a newer invoice.',
        ),
      );
    }

    final paid = invoice.status == InvoiceStatus.paid;
    final sameDay = invoice.periodStart == invoice.periodEnd;

    return Scaffold(
      appBar: const SfAppBar(title: 'Invoice'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Insets.page, Insets.sm, Insets.page, Insets.xxl),
        children: [
          SfCard(
            padding: const EdgeInsets.all(Insets.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(invoice.title, style: context.text.titleLarge)),
                    SfStatusChip(label: paid ? 'Paid' : 'Due', tone: paid ? SfTone.success : SfTone.warning),
                  ],
                ),
                const Gap(Insets.lg),
                Text(kes(invoice.total, cents: true), style: context.text.displaySmall),
                const Gap(Insets.xs),
                Text('Issued ${fmtDate(invoice.issuedAt)}', style: context.text.bodySmall),
              ],
            ),
          ),
          const Gap(Insets.xl),
          SfGroup(
            title: 'Details',
            children: [
              SfInfoRow(label: 'Invoice number', value: invoice.id),
              SfInfoRow(label: 'Account', value: account),
              SfInfoRow(
                label: sameDay ? 'Date' : 'Service period',
                value: sameDay
                    ? fmtDate(invoice.periodStart)
                    : '${fmtDate(invoice.periodStart)} to ${fmtDate(invoice.periodEnd)}',
              ),
              if (invoice.paidWith != null) SfInfoRow(label: 'Paid with', value: invoice.paidWith!.label),
            ],
          ),
          const Gap(Insets.xl),
          SfGroup(
            title: 'Charges',
            children: [
              for (final line in invoice.lines)
                SfInfoRow(label: line.description, value: kes(line.amount, cents: true)),
              SfInfoRow(label: 'Total', value: kes(invoice.total, cents: true), emphasize: true),
            ],
          ),
          const Gap(Insets.xxl),
          Row(
            children: [
              Expanded(
                child: SfButton(
                  label: 'Download PDF',
                  icon: PhosphorIconsRegular.downloadSimple,
                  variant: SfButtonVariant.ghost,
                  compact: true,
                  onPressed: () => showSfSnack(context, 'PDF downloads arrive once billing is connected'),
                ),
              ),
              const Gap(Insets.sm + 2),
              Expanded(
                child: SfButton(
                  label: 'Share',
                  icon: PhosphorIconsRegular.shareNetwork,
                  variant: SfButtonVariant.ghost,
                  compact: true,
                  onPressed: () => showSfSnack(context, 'Sharing arrives once billing is connected'),
                ),
              ),
            ],
          ),
        ].staggered(),
      ),
    );
  }
}
