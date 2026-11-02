import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/widgets/widgets.dart';
import '../../data/models/billing.dart';
import '../../data/models/plan.dart';
import '../../state/account_providers.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    final wallet = ref.watch(walletProvider);
    final invoices = ref.watch(invoicesProvider);
    final connection = ref.watch(connectionProvider);
    final expired = connection.status(DateTime.now()) == ConnectionStatus.expired;

    return Scaffold(
      appBar: const SfAppBar(title: 'Billing'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Insets.page, Insets.sm, Insets.page, Insets.xxxl),
          children: [
            SfCard(
              padding: const EdgeInsets.all(Insets.lg + 2),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _Metric(label: 'Wallet balance', value: kes(wallet.balance, cents: true)),
                      ),
                      Container(width: 1, height: 40, color: p.line),
                      const Gap(Insets.lg),
                      Expanded(
                        child: _Metric(
                          label: expired ? 'Plan ended' : 'Plan ends',
                          value: fmtDate(connection.expiresAt),
                          valueColor: expired ? p.danger : null,
                        ),
                      ),
                    ],
                  ),
                  const Gap(Insets.lg),
                  Row(
                    children: [
                      Expanded(
                        child: SfButton(label: 'Top up', compact: true, onPressed: () => context.push('/top-up')),
                      ),
                      const Gap(Insets.sm + 2),
                      Expanded(
                        child: SfButton(
                          label: 'Renew plan',
                          compact: true,
                          variant: SfButtonVariant.ghost,
                          onPressed: () => context.push('/renew'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(Insets.xxl),
            SfSegmented(
              labels: const ['Invoices', 'Payments'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const Gap(Insets.lg),
            if (_tab == 0) ...[
              if (invoices.isEmpty)
                const SfEmptyState(
                  icon: PhosphorIconsRegular.receipt,
                  title: 'No invoices yet',
                  message: 'Invoices appear here each time your plan renews.',
                )
              else
                for (final invoice in invoices)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Insets.sm + 2),
                    child: _InvoiceTile(invoice: invoice),
                  ),
            ] else ...[
              if (wallet.transactions.isEmpty)
                SfEmptyState(
                  icon: PhosphorIconsRegular.arrowsDownUp,
                  title: 'No payments yet',
                  message: 'Top-ups and plan payments will show up here.',
                  actionLabel: 'Top up wallet',
                  onAction: () => context.push('/top-up'),
                )
              else
                SfCard(
                  padding: const EdgeInsets.symmetric(horizontal: Insets.lg),
                  child: Column(
                    children: [
                      for (var i = 0; i < wallet.transactions.length; i++) ...[
                        if (i > 0) const Divider(),
                        _TransactionRow(tx: wallet.transactions[i]),
                      ],
                    ],
                  ),
                ),
            ],
          ].staggered(),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.text.labelMedium),
        const Gap(Insets.xs),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, maxLines: 1, style: context.text.titleLarge!.copyWith(color: valueColor)),
        ),
      ],
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  const _InvoiceTile({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    final paid = invoice.status == InvoiceStatus.paid;
    return SfCard(
      onTap: () => context.push('/invoice/${invoice.id}'),
      child: Row(
        children: [
          SfIconBox(icon: PhosphorIconsRegular.receipt, background: p.surfaceAlt, foreground: p.inkMuted),
          const Gap(Insets.md + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invoice.title, style: context.text.titleSmall),
                const Gap(2),
                Text(fmtDate(invoice.issuedAt), style: context.text.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(kes(invoice.total, cents: true), style: context.text.titleSmall),
              const Gap(Insets.xs),
              SfStatusChip(label: paid ? 'Paid' : 'Due', tone: paid ? SfTone.success : SfTone.warning),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.tx});

  final WalletTransaction tx;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          SfIconBox(
            icon: tx.isCredit ? PhosphorIconsBold.arrowDownLeft : PhosphorIconsBold.arrowUpRight,
            size: 38,
            iconSize: 18,
            radius: 12,
            background: tx.isCredit ? p.successSoft : p.surfaceAlt,
            foreground: tx.isCredit ? p.success : p.inkMuted,
          ),
          const Gap(Insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title, style: context.text.titleSmall),
                const Gap(2),
                Text('${tx.method.label}, ${fmtDateTime(tx.at)}', style: context.text.bodySmall),
              ],
            ),
          ),
          Text(
            '${tx.isCredit ? '+' : '−'}${kes(tx.amount.abs())}',
            style: context.text.titleSmall!.copyWith(color: tx.isCredit ? p.success : p.ink),
          ),
        ],
      ),
    );
  }
}
