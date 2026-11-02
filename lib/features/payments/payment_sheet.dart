import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/widgets/widgets.dart';
import '../../data/models/billing.dart';
import '../../state/account_providers.dart';

/// Lets the customer pay from their wallet or by M-Pesa, then runs [onPay].
/// Resolves to true when the payment went through.
Future<bool?> showPaymentSheet(
  BuildContext context, {
  required String title,
  required double amount,
  required Future<void> Function(PaymentMethod method) onPay,
}) {
  return showSfSheet<bool>(
    context,
    builder: (_) => PaymentSheet(title: title, amount: amount, onPay: onPay),
  );
}

class PaymentSheet extends ConsumerStatefulWidget {
  const PaymentSheet({super.key, required this.title, required this.amount, required this.onPay});

  final String title;
  final double amount;
  final Future<void> Function(PaymentMethod method) onPay;

  @override
  ConsumerState<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<PaymentSheet> {
  PaymentMethod? _method;
  bool _busy = false;
  String? _error;

  Future<void> _pay() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onPay(_method!);
      if (mounted) Navigator.of(context).pop(true);
    } on InsufficientFundsException {
      if (mounted) setState(() => _error = 'Your wallet balance is too low for this payment.');
    } catch (_) {
      if (mounted) setState(() => _error = "The payment didn't go through. Try again.");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    final t = context.text;
    final balance = ref.watch(walletProvider.select((w) => w.balance));
    final phone = ref.watch(customerProvider.select((c) => c.primaryPhone));
    final walletCovers = balance >= widget.amount;
    _method ??= walletCovers ? PaymentMethod.wallet : PaymentMethod.mpesa;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: t.headlineSmall),
        const Gap(Insets.xs),
        Text('Choose how to pay ${kes(widget.amount)}.', style: t.bodyMedium!.copyWith(color: p.inkMuted)),
        const Gap(Insets.xl),
        _MethodTile(
          icon: PhosphorIconsRegular.wallet,
          title: 'Wallet',
          subtitle: walletCovers
              ? 'Balance ${kes(balance, cents: true)}'
              : 'Balance ${kes(balance, cents: true)}. Top up to pay from your wallet.',
          selected: _method == PaymentMethod.wallet,
          enabled: walletCovers && !_busy,
          onTap: () => setState(() => _method = PaymentMethod.wallet),
          trailing: walletCovers
              ? null
              : TextButton(
                  onPressed: _busy
                      ? null
                      : () {
                          Navigator.of(context).pop(false);
                          context.push('/top-up');
                        },
                  style: TextButton.styleFrom(foregroundColor: p.accentDeep),
                  child: const Text('Top up'),
                ),
        ),
        const Gap(Insets.sm + 2),
        _MethodTile(
          icon: PhosphorIconsRegular.deviceMobile,
          title: 'M-Pesa',
          subtitle: "We'll send a payment prompt to ${fmtPhone(phone)}",
          selected: _method == PaymentMethod.mpesa,
          enabled: !_busy,
          onTap: () => setState(() => _method = PaymentMethod.mpesa),
        ),
        if (_error != null) ...[const Gap(Insets.md), Text(_error!, style: t.bodySmall!.copyWith(color: p.danger))],
        const Gap(Insets.xl),
        SfButton(label: 'Pay ${kes(widget.amount)}', loading: _busy, onPressed: _pay),
        if (_method == PaymentMethod.mpesa) ...[
          const Gap(Insets.sm + 2),
          Center(
            child: Text(
              _busy ? 'Check your phone and enter your M-Pesa PIN.' : 'You confirm the payment with your M-Pesa PIN.',
              style: t.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    return Semantics(
      selected: selected,
      enabled: enabled,
      button: true,
      child: Opacity(
        opacity: enabled || trailing != null ? 1 : 0.5,
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
              onTap: enabled ? onTap : null,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    SfIconBox(
                      icon: icon,
                      size: 40,
                      iconSize: 20,
                      radius: 12,
                      background: selected ? p.accentSoft : p.surfaceAlt,
                      foreground: selected ? p.accentDeep : p.inkMuted,
                    ),
                    const Gap(Insets.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: context.text.titleSmall),
                          const Gap(2),
                          Text(subtitle, style: context.text.bodySmall),
                        ],
                      ),
                    ),
                    if (trailing != null)
                      trailing!
                    else
                      Icon(
                        selected ? PhosphorIconsFill.checkCircle : PhosphorIconsRegular.circle,
                        color: selected ? p.accent : p.line,
                        size: 22,
                      ),
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
