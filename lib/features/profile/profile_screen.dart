import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/widgets/widgets.dart';
import '../../state/account_providers.dart';
import '../../state/auth_controller.dart';
import 'widgets/edit_contact_sheet.dart';
import 'widgets/map_preview.dart';
import 'widgets/profile_header.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text("You'll need a new code to sign back in."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: dialogContext.sf.danger,
            ),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true) ref.read(authProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.sf;
    final customer = ref.watch(customerProvider);
    final customerCtrl = ref.read(customerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const SfAppBar(title: 'My profile'),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                Insets.page,
                Insets.sm,
                Insets.page,
                Insets.xxxl,
              ),
              children: [
                ProfileHeader(customer: customer),
                const Gap(Insets.xxxl),
                _Section(
                  title: 'Contact details',
                  subtitle: 'How we keep in touch with you',
                  action: TextButton.icon(
                    onPressed: () => showSfSheet<void>(
                      context,
                      builder: (_) => const EditContactSheet(),
                    ),
                    icon: const Icon(
                      PhosphorIconsRegular.pencilSimple,
                      size: 16,
                    ),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(foregroundColor: p.accentDeep),
                  ),
                  children: [
                    _DetailRow(
                      icon: PhosphorIconsRegular.deviceMobile,
                      label: 'Mobile number',
                      value: fmtPhone(customer.primaryPhone),
                    ),
                    _DetailRow(
                      icon: PhosphorIconsRegular.phone,
                      label: 'Second mobile',
                      value: customer.secondaryPhone == null
                          ? 'Not added'
                          : fmtPhone(customer.secondaryPhone!),
                      placeholder: customer.secondaryPhone == null,
                    ),
                    _DetailRow(
                      icon: PhosphorIconsRegular.envelopeSimple,
                      label: 'Email address',
                      value: customer.email,
                    ),
                  ],
                ),
                const Gap(Insets.xxl),
                _Section(
                  title: 'Installation',
                  subtitle: 'Where your fibre feels at home',
                  leading: Padding(
                    padding: const EdgeInsets.only(
                      top: Insets.lg,
                      bottom: Insets.xs,
                    ),
                    child: MapPreview(
                      latitude: customer.address.latitude,
                      longitude: customer.address.longitude,
                    ),
                  ),
                  children: [
                    _DetailRow(
                      icon: PhosphorIconsRegular.mapPin,
                      label: 'Service area',
                      value: customer.address.serviceArea,
                    ),
                    _DetailRow(
                      icon: PhosphorIconsRegular.buildings,
                      label: 'Branch',
                      value: customer.address.branch,
                    ),
                    if (customer.address.road != null)
                      _DetailRow(
                        icon: PhosphorIconsRegular.path,
                        label: 'Road',
                        value: customer.address.road!,
                      ),
                    if (customer.address.landmark != null)
                      _DetailRow(
                        icon: PhosphorIconsRegular.flag,
                        label: 'Landmark',
                        value: customer.address.landmark!,
                      ),
                    if (customer.address.unit != null)
                      _DetailRow(
                        icon: PhosphorIconsRegular.house,
                        label: 'Unit',
                        value: customer.address.unit!,
                      ),
                  ],
                ),
                const Gap(Insets.xxl),
                _Section(
                  title: 'Preferences',
                  subtitle: 'Make Savanna feel like you',
                  children: [
                    _PreferenceRow(
                      icon: PhosphorIconsRegular.bell,
                      title: 'Payment reminders',
                      subtitle: 'An SMS before your plan ends',
                      value: customer.paymentReminders,
                      onChanged: customerCtrl.setPaymentReminders,
                    ),
                    _PreferenceRow(
                      icon: PhosphorIconsRegular.broadcast,
                      title: 'Service alerts',
                      subtitle: 'Outages and maintenance nearby',
                      value: customer.serviceAlerts,
                      onChanged: customerCtrl.setServiceAlerts,
                    ),
                    _PreferenceRow(
                      icon: PhosphorIconsRegular.moon,
                      title: 'Dark mode',
                      subtitle: 'A little easier on the eyes',
                      value: isDark,
                      onChanged: ref.read(themeModeProvider.notifier).setDark,
                    ),
                  ],
                ),
                const Gap(Insets.xxl),
                SfCard(
                  onTap: () => context.push('/help'),
                  color: p.accentSoft,
                  borderColor: p.accent.withValues(alpha: 0.2),
                  padding: const EdgeInsets.all(Insets.xl),
                  child: Row(
                    children: [
                      SfIconBox(
                        icon: PhosphorIconsRegular.headset,
                        background: p.surface,
                        foreground: p.accentDeep,
                      ),
                      const Gap(Insets.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Here to help',
                              style: context.text.titleMedium,
                            ),
                            const Gap(4),
                            Text(
                              'Visit the help centre',
                              style: context.text.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Gap(Insets.sm),
                      Icon(
                        PhosphorIconsRegular.arrowUpRight,
                        size: 20,
                        color: p.accentDeep,
                      ),
                    ],
                  ),
                ),
                const Gap(Insets.lg),
                TextButton.icon(
                  onPressed: () => _signOut(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: p.danger,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Radii.md),
                      side: BorderSide(color: p.danger.withValues(alpha: 0.2)),
                    ),
                  ),
                  icon: const Icon(PhosphorIconsRegular.signOut, size: 20),
                  label: const Text('Sign out'),
                ),
                const Gap(Insets.xxl),
                Center(
                  child: Text(
                    'Savanna Fibre · Version 1.0.0',
                    style: context.text.labelSmall,
                  ),
                ),
              ].staggered(),
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.subtitle,
    required this.children,
    this.action,
    this.leading,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? action;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: Insets.xs, bottom: Insets.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.titleLarge),
                    const Gap(4),
                    Text(subtitle, style: context.text.bodySmall),
                  ],
                ),
              ),
              if (action != null) ...[const Gap(Insets.sm), action!],
            ],
          ),
        ),
        SfCard(
          padding: const EdgeInsets.symmetric(horizontal: Insets.lg),
          child: Column(
            children: [
              ?leading,
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.placeholder = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool placeholder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.lg),
      child: Row(
        children: [
          SfIconBox(
            icon: icon,
            size: 40,
            iconSize: 20,
            background: context.sf.surfaceAlt,
            foreground: context.sf.inkMuted,
          ),
          const Gap(Insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.text.bodySmall),
                const Gap(4),
                Text(
                  value,
                  style: context.text.titleSmall!.copyWith(
                    color: placeholder ? context.sf.inkMuted : context.sf.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(Radii.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Insets.md),
          child: Row(
            children: [
              SfIconBox(
                icon: icon,
                size: 40,
                iconSize: 20,
                background: context.sf.surfaceAlt,
                foreground: context.sf.inkMuted,
              ),
              const Gap(Insets.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.titleSmall),
                    const Gap(4),
                    Text(subtitle, style: context.text.bodySmall),
                  ],
                ),
              ),
              const Gap(Insets.sm),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}
