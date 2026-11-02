import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/widgets/widgets.dart';
import '../../state/account_providers.dart';

class TopUpScreen extends ConsumerStatefulWidget {
  const TopUpScreen({super.key});

  @override
  ConsumerState<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends ConsumerState<TopUpScreen> {
  static const _presets = [500, 1000, 2500, 5000];
  static const _min = 10;
  static const _max = 150000;

  final _amount = TextEditingController();
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final e164 = ref.read(customerProvider).primaryPhone;
    _phone = TextEditingController(text: '0${e164.substring(4)}');
  }

  @override
  void dispose() {
    _amount.dispose();
    _phone.dispose();
    super.dispose();
  }

  int get _value => int.tryParse(_amount.text) ?? 0;
  String? get _normalisedPhone => normaliseKePhone(_phone.text);
  bool get _valid => _value >= _min && _value <= _max && _normalisedPhone != null;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final amount = _value.toDouble();
    final navigator = Navigator.of(context);

    showSfSheet<void>(context, dismissible: false, builder: (_) => const _MpesaPendingSheet());
    try {
      await ref.read(walletProvider.notifier).topUp(amount, _normalisedPhone!);
      if (!mounted) return;
      navigator.pop();
      final balance = ref.read(walletProvider).balance;
      await showSuccessSheet(
        context,
        title: 'Wallet topped up',
        message: '${kes(amount)} added. Your balance is now ${kes(balance, cents: true)}.',
      );
      if (mounted) context.pop();
    } catch (_) {
      if (!mounted) return;
      navigator.pop();
      showSfSnack(context, "The M-Pesa request didn't go through. Try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    final t = context.text;
    final tooHigh = _value > _max;

    return Scaffold(
      appBar: const SfAppBar(title: 'Top up wallet'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Insets.page, Insets.sm, Insets.page, Insets.xxl),
        children: [
          SfCard(
            padding: const EdgeInsets.all(Insets.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Amount', style: t.labelMedium),
                TextField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                  style: t.displayMedium,
                  decoration: InputDecoration(
                    prefixText: 'KES ',
                    prefixStyle: t.headlineMedium!.copyWith(color: p.inkMuted),
                    hintText: '0',
                    hintStyle: t.displayMedium!.copyWith(color: p.line),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: Insets.sm),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                if (tooHigh)
                  Text(
                    'The most you can top up at once is ${kes(_max)}.',
                    style: t.bodySmall!.copyWith(color: p.danger),
                  ),
                const Gap(Insets.md),
                Wrap(
                  spacing: Insets.sm,
                  runSpacing: Insets.sm,
                  children: [
                    for (final preset in _presets)
                      SfChoicePill(
                        label: kes(preset),
                        selected: _value == preset,
                        onTap: () => setState(() {
                          _amount.text = '$preset';
                          _amount.selection = TextSelection.collapsed(offset: _amount.text.length);
                        }),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(Insets.lg),
          Text('Pay from this M-Pesa number', style: t.titleSmall),
          const Gap(Insets.sm),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 +]'))],
            style: t.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              prefixIcon: Icon(PhosphorIconsRegular.deviceMobile, color: p.inkMuted),
              hintText: '07XX XXX XXX',
              errorText: _phone.text.isNotEmpty && _normalisedPhone == null ? 'Enter a Kenyan mobile number' : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const Gap(Insets.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(PhosphorIconsRegular.info, size: 18, color: p.inkMuted),
              const Gap(Insets.sm),
              Expanded(
                child: Text(
                  "You'll get an M-Pesa prompt on this phone. Enter your PIN and the money lands in your wallet in seconds.",
                  style: t.bodySmall,
                ),
              ),
            ],
          ),
        ].staggered(),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Insets.page, Insets.sm, Insets.page, Insets.md),
          child: SfButton(
            label: _value >= _min ? 'Top up ${kes(_value)}' : 'Enter an amount',
            onPressed: _valid ? _submit : null,
          ),
        ),
      ),
    );
  }
}

class _MpesaPendingSheet extends StatelessWidget {
  const _MpesaPendingSheet();

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    return PopScope(
      canPop: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 64,
            child: CircularProgressIndicator(strokeWidth: 3, color: p.accent, backgroundColor: p.accentSoft),
          ),
          const Gap(Insets.xl),
          Text('Check your phone', style: context.text.headlineSmall),
          const Gap(6),
          Text(
            'Enter your M-Pesa PIN to confirm. This usually takes a few seconds.',
            style: context.text.bodyMedium!.copyWith(color: p.inkMuted),
            textAlign: TextAlign.center,
          ),
          const Gap(Insets.lg),
        ],
      ),
    );
  }
}
