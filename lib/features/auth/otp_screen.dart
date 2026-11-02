import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/widgets.dart';
import '../../state/auth_controller.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _length = 6;
  static const _resendAfter = 30;

  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  int _seconds = _resendAfter;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = _resendAfter;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds <= 1) timer.cancel();
      if (mounted) setState(() => _seconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_busy || _controller.text.length != _length) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await ref.read(authProvider.notifier).verify(_controller.text);
    if (!mounted) return;
    // On success the router redirects to /home.
    if (!ok) {
      HapticFeedback.heavyImpact();
      setState(() {
        _busy = false;
        _error = "That code didn't match. Check the SMS and try again.";
        _controller.clear();
      });
    }
  }

  Future<void> _resend() async {
    await ref.read(authProvider.notifier).resendCode();
    if (!mounted) return;
    setState(_startTimer);
    showSfSnack(context, 'New code sent');
  }

  void _changeNumber() {
    ref.read(authProvider.notifier).signOut();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    final t = context.text;
    final phone = fmtPhone(ref.watch(authProvider).phone);
    final code = _controller.text;

    return Scaffold(
      appBar: const SfAppBar(title: ''),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Insets.xxl, Insets.sm, Insets.xxl, Insets.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter the code', style: t.headlineLarge),
              const Gap(Insets.sm),
              Text.rich(
                TextSpan(
                  text: 'We sent a 6-digit code to ',
                  children: [
                    TextSpan(
                      text: phone,
                      style: TextStyle(color: p.ink, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                style: t.bodyLarge!.copyWith(color: p.inkMuted),
              ),
              TextButton(
                onPressed: _changeNumber,
                style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: p.accentDeep),
                child: const Text('Change number'),
              ),
              const Gap(Insets.lg),
              Animate(
                target: _error != null ? 1 : 0,
                effects: const [ShakeEffect(duration: Duration(milliseconds: 420), hz: 5, offset: Offset(8, 0))],
                child: _CodeField(
                  controller: _controller,
                  focusNode: _focus,
                  length: _length,
                  hasError: _error != null,
                  onChanged: (value) {
                    setState(() => _error = null);
                    if (value.length == _length) _verify();
                  },
                ),
              ),
              SfInlineError(_error, color: p.danger, style: t.bodySmall!),
              const Gap(Insets.lg),
              _seconds > 0
                  ? Text(
                      'Resend code in 0:${_seconds.toString().padLeft(2, '0')}',
                      style: t.bodyMedium!.copyWith(color: p.inkMuted),
                    )
                  : TextButton(
                      onPressed: _resend,
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: p.accentDeep),
                      child: const Text('Resend code'),
                    ),
              const Spacer(),
              Center(
                child: Text(
                  'Demo build: any 6 digits will sign you in.',
                  style: t.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const Gap(Insets.md),
              SfButton(
                label: 'Verify and continue',
                loading: _busy,
                onPressed: code.length == _length ? _verify : null,
              ),
            ].staggered(),
          ),
        ),
      ),
    );
  }
}

/// Six boxes over a single invisible text field, so paste and SMS autofill
/// work as usual.
class _CodeField extends StatelessWidget {
  const _CodeField({
    required this.controller,
    required this.focusNode,
    required this.length,
    required this.hasError,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final bool hasError;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    final code = controller.text;

    return SizedBox(
      height: 60,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                maxLength: length,
                showCursor: false,
                enableInteractiveSelection: false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(counterText: '', filled: false),
                onChanged: onChanged,
              ),
            ),
          ),
          IgnorePointer(
            child: Row(
              children: [
                for (var i = 0; i < length; i++) ...[
                  if (i > 0) const Gap(Insets.sm),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: p.surface,
                        borderRadius: BorderRadius.circular(Radii.md),
                        border: Border.all(
                          width: 1.5,
                          color: hasError
                              ? p.danger
                              : i == code.length && focusNode.hasFocus
                              ? p.accent
                              : i < code.length
                              ? p.ink.withValues(alpha: 0.4)
                              : p.line,
                        ),
                      ),
                      child: Text(i < code.length ? code[i] : '', style: context.text.headlineMedium),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
