import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/widgets/widgets.dart';
import '../../state/account_providers.dart';
import 'widgets/plan_hero_card.dart';
import 'widgets/promo_carousel.dart';
import 'widgets/quick_actions.dart';
import 'widgets/wallet_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(connectionProvider);

    // One orchestrated entrance when the screen first appears.
    final sections = <Widget>[
      const _Header(),
      const Gap(Insets.xl),
      PlanHeroCard(connection: connection),
      const Gap(Insets.md + 2),
      const WalletCard(),
      const Gap(Insets.xxl + 4),
      const SfSectionHeader(title: 'Quick actions'),
      const Gap(Insets.md),
      const QuickActions(),
      const Gap(Insets.xxxl),
      const SfSectionHeader(title: 'For you'),
      const Gap(Insets.md),
      const PromoCarousel(),
    ].staggered();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Insets.page, Insets.md, Insets.page, Insets.xxxl),
          children: sections,
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.sf;
    final customer = ref.watch(customerProvider);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting(DateTime.now()), style: context.text.bodyMedium!.copyWith(color: p.inkMuted)),
              const Gap(2),
              Text(customer.firstName, style: context.text.headlineMedium),
            ],
          ),
        ),
        Material(
          color: p.surface,
          shape: CircleBorder(side: BorderSide(color: p.line)),
          child: IconButton(
            tooltip: 'Notifications',
            icon: Icon(PhosphorIconsRegular.bell, color: p.ink, size: 22),
            onPressed: () => showSfSnack(context, "You're all caught up"),
          ),
        ),
        const Gap(Insets.sm + 2),
        Semantics(
          button: true,
          label: 'Profile',
          child: GestureDetector(
            onTap: () => context.push('/profile'),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: p.accent,
              child: Text(customer.initials, style: context.text.titleMedium!.copyWith(color: p.onAccent)),
            ),
          ),
        ),
      ],
    );
  }
}
