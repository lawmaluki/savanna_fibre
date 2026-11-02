import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/widgets.dart';
import '../../state/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _controller = TextEditingController();
  bool _useAccount = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _valid {
    final v = _controller.text.trim();
    if (_useAccount) return RegExp(r'^[A-Za-z]{2,5}\d{3,}$').hasMatch(v);
    return normaliseKePhone(v) != null;
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).sendCode(_controller.text.trim());
      if (mounted) context.push('/otp');
    } catch (_) {
      if (mounted) setState(() => _error = "We couldn't send a code. Check your connection and try again.");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    final t = context.text;

    return Scaffold(
      backgroundColor: p.bg,
      body: LayoutBuilder(
        builder: (context, constraints) => CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Hero(height: (constraints.maxHeight * 0.36).clamp(240.0, 320.0)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(Insets.xxl, Insets.xxxl, Insets.xxl, Insets.xxl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sign in', style: t.headlineLarge),
                          const Gap(Insets.sm),
                          Text(
                            _useAccount
                                ? "Enter your account number. We'll text a code to the phone on the account."
                                : 'Use the phone number linked to your fibre account.',
                            style: t.bodyLarge!.copyWith(color: p.inkMuted),
                          ),
                          const Gap(Insets.xxl),
                          Text(_useAccount ? 'Account number' : 'Phone number', style: t.titleSmall),
                          const Gap(Insets.sm),
                          TextField(
                            key: ValueKey(_useAccount),
                            controller: _controller,
                            keyboardType: _useAccount ? TextInputType.text : TextInputType.phone,
                            textCapitalization: _useAccount ? TextCapitalization.characters : TextCapitalization.none,
                            autofillHints: _useAccount ? null : const [AutofillHints.telephoneNumber],
                            inputFormatters: _useAccount
                                ? [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))]
                                : [FilteringTextInputFormatter.allow(RegExp(r'[0-9 +]'))],
                            style: t.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              prefixText: _useAccount ? null : '+254  ',
                              hintText: _useAccount ? 'e.g. SFKL2551' : '7XX XXX XXX',
                            ),
                            onChanged: (_) => setState(() => _error = null),
                            onSubmitted: (_) => _valid ? _send() : null,
                          ),
                          SfInlineError(_error, color: p.danger, style: t.bodySmall!),
                          const Gap(Insets.xl),
                          SfButton(label: 'Send code', loading: _busy, onPressed: _valid ? _send : null),
                          const Gap(Insets.sm),
                          Center(
                            child: TextButton(
                              onPressed: () => setState(() {
                                _useAccount = !_useAccount;
                                _controller.clear();
                                _error = null;
                              }),
                              child: Text(_useAccount ? 'Use phone number instead' : 'Use account number instead'),
                            ),
                          ),
                          const Spacer(),
                          const Gap(Insets.lg),
                          Center(
                            child: Text(
                              'Not connected yet? Call us to check coverage in your area.',
                              style: t.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ].staggered(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: p.hero,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Radii.xl + 8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: FibreStrands(color: p.accent)),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Insets.xxl, Insets.lg, Insets.xxl, Insets.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SavannaWordmark(color: p.heroInk, size: 30),
                  const Spacer(),
                  Text(
                    'Fast, steady fibre\nfor your home.',
                    style: context.text.displaySmall!.copyWith(color: p.heroInk),
                  ),
                  const Gap(Insets.sm),
                  Text(
                    'Renew, top up and get help in one place.',
                    style: context.text.bodyMedium!.copyWith(color: p.heroMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
