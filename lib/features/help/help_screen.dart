import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/widgets/widgets.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqs = <(String, String)>[
    (
      'My internet is down',
      'Check that the router power light is on. Turn the router off at the socket, wait 30 seconds and turn it back on. '
          'If the LOS or PON light is red after that, report an issue so a technician can check your line.',
    ),
    (
      'My internet is slow',
      'Wi-Fi slows down far from the router and behind thick walls. Test close to the router, or on a cable if you can. '
          'If it is still slow, report an issue and tell us the speed you got.',
    ),
    (
      'How do I pay with M-Pesa?',
      'Open Top up, enter an amount and your M-Pesa number. You get a prompt on your phone to enter your PIN, '
          'and the money lands in your wallet within seconds.',
    ),
    (
      'What happens when my plan ends?',
      'Your internet pauses until you renew. Renew from Home with your wallet or M-Pesa and you are back online right away.',
    ),
    (
      'Can I change my plan?',
      'Yes. Pick any plan on the Renew screen. The new speed starts as soon as the payment goes through.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    final t = context.text;
    void notConnected() => showSfSnack(context, 'Support contacts are added when the app goes live');

    return Scaffold(
      appBar: const SfAppBar(title: 'Help centre'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Insets.page, Insets.sm, Insets.page, Insets.xxl),
        children: [
          Text('Talk to us', style: t.titleLarge),
          const Gap(Insets.md),
          Row(
            children: [
              Expanded(
                child: _ContactTile(icon: PhosphorIconsRegular.phone, label: 'Call', onTap: notConnected),
              ),
              const Gap(Insets.sm + 2),
              Expanded(
                child: _ContactTile(icon: PhosphorIconsRegular.whatsappLogo, label: 'WhatsApp', onTap: notConnected),
              ),
              const Gap(Insets.sm + 2),
              Expanded(
                child: _ContactTile(icon: PhosphorIconsRegular.envelopeSimple, label: 'Email', onTap: notConnected),
              ),
            ],
          ),
          const Gap(Insets.xxl + 4),
          Text('Common questions', style: t.titleLarge),
          const Gap(Insets.md),
          SfCard(
            padding: EdgeInsets.zero,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: Column(
                children: [
                  for (var i = 0; i < _faqs.length; i++) ...[
                    if (i > 0) Divider(indent: Insets.lg, endIndent: Insets.lg, color: p.line),
                    ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: Insets.lg),
                      childrenPadding: const EdgeInsets.fromLTRB(Insets.lg, 0, Insets.lg, Insets.lg),
                      expandedAlignment: Alignment.centerLeft,
                      iconColor: p.accentDeep,
                      collapsedIconColor: p.inkMuted,
                      title: Text(_faqs[i].$1, style: t.titleSmall),
                      children: [Text(_faqs[i].$2, style: t.bodyMedium!.copyWith(color: p.inkMuted))],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Gap(Insets.xxl),
          SfCard(
            child: Row(
              children: [
                const SfIconBox(icon: PhosphorIconsRegular.lifebuoy),
                const Gap(Insets.md + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Still stuck?', style: t.titleSmall),
                      Text('Send a ticket and we\'ll call you back.', style: t.bodySmall),
                    ],
                  ),
                ),
                SfButton(label: 'Report', compact: true, expand: false, onPressed: () => context.push('/tickets/new')),
              ],
            ),
          ),
        ].staggered(),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: Insets.lg),
      child: Column(
        children: [
          Icon(icon, size: 26, color: context.sf.ink),
          const Gap(Insets.sm),
          Text(label, style: context.text.titleSmall),
        ],
      ),
    );
  }
}
