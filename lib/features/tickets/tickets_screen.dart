import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/widgets/widgets.dart';
import '../../data/models/ticket.dart';
import '../../state/account_providers.dart';
import 'ticket_ui.dart';

enum _Filter { all, open, resolved }

class TicketsScreen extends ConsumerStatefulWidget {
  const TicketsScreen({super.key});

  @override
  ConsumerState<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends ConsumerState<TicketsScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final tickets = ref.watch(ticketsProvider);
    final open = tickets.where((t) => t.isOpen).toList();
    final resolved = tickets.where((t) => !t.isOpen).toList();
    final shown = switch (_filter) {
      _Filter.all => tickets,
      _Filter.open => open,
      _Filter.resolved => resolved,
    };

    return Scaffold(
      appBar: SfAppBar(
        title: 'Support',
        actions: [
          SfButton(
            label: 'New ticket',
            icon: PhosphorIconsBold.plus,
            compact: true,
            expand: false,
            variant: SfButtonVariant.secondary,
            onPressed: () => context.push('/tickets/new'),
          ),
          const Gap(Insets.page - Insets.sm),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Insets.page, Insets.sm, Insets.page, Insets.xxxl),
          children: [
            const _QuickFixBanner(),
            const Gap(Insets.xxl),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  SfChoicePill(
                    label: 'All ${tickets.length}',
                    selected: _filter == _Filter.all,
                    onTap: () => setState(() => _filter = _Filter.all),
                  ),
                  const Gap(Insets.sm),
                  SfChoicePill(
                    label: 'Open ${open.length}',
                    selected: _filter == _Filter.open,
                    onTap: () => setState(() => _filter = _Filter.open),
                  ),
                  const Gap(Insets.sm),
                  SfChoicePill(
                    label: 'Resolved ${resolved.length}',
                    selected: _filter == _Filter.resolved,
                    onTap: () => setState(() => _filter = _Filter.resolved),
                  ),
                ],
              ),
            ),
            const Gap(Insets.lg),
            if (shown.isEmpty)
              SfEmptyState(
                icon: PhosphorIconsRegular.lifebuoy,
                title: _filter == _Filter.open ? 'No open tickets' : 'No tickets here',
                message: 'If something isn\'t working, report it and we\'ll get back to you.',
                actionLabel: 'Report an issue',
                onAction: () => context.push('/tickets/new'),
              )
            else
              for (final ticket in shown)
                Padding(
                  padding: const EdgeInsets.only(bottom: Insets.sm + 2),
                  child: _TicketCard(ticket: ticket),
                ),
          ].staggered(),
        ),
      ),
    );
  }
}

class _QuickFixBanner extends StatelessWidget {
  const _QuickFixBanner();

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    return Container(
      padding: const EdgeInsets.all(Insets.lg + 2),
      decoration: BoxDecoration(color: p.hero, borderRadius: BorderRadius.circular(Radii.lg + 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsFill.lightbulb, color: p.accent, size: 20),
              const Gap(Insets.sm),
              Text('Internet down or slow?', style: context.text.titleMedium!.copyWith(color: p.heroInk)),
            ],
          ),
          const Gap(6),
          Text(
            'Turn the router off at the socket, wait 30 seconds and turn it back on. That fixes most problems.',
            style: context.text.bodySmall!.copyWith(color: p.heroMuted),
          ),
          const Gap(Insets.md + 2),
          Row(
            children: [
              SfButton(
                label: 'Report an issue',
                compact: true,
                expand: false,
                onPressed: () => context.push('/tickets/new?category=no_internet'),
              ),
              const Gap(Insets.sm),
              TextButton(
                onPressed: () => context.push('/help'),
                style: TextButton.styleFrom(foregroundColor: p.heroInk),
                child: const Text('Help centre'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    final followUp = ticket.isOpen && ticket.followUpAt != null;
    return SfCard(
      onTap: () => context.push('/tickets/${ticket.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(ticket.subject, style: context.text.titleMedium)),
              TicketStatusChip(status: ticket.status),
            ],
          ),
          const Gap(Insets.xs),
          Text('${ticket.id}, ${ticket.category}', style: context.text.bodySmall),
          const Gap(Insets.md),
          const Divider(),
          const Gap(Insets.md),
          Row(
            children: [
              Icon(
                followUp ? PhosphorIconsRegular.phoneCall : PhosphorIconsRegular.clockCounterClockwise,
                size: 16,
                color: p.inkMuted,
              ),
              const Gap(6),
              Expanded(
                child: Text(
                  followUp ? 'We call you ${fmtDateTime(ticket.followUpAt!)}' : 'Updated ${fmtDate(ticket.updatedAt)}',
                  style: context.text.bodySmall,
                ),
              ),
              Icon(PhosphorIconsRegular.caretRight, size: 16, color: p.inkMuted),
            ],
          ),
        ],
      ),
    );
  }
}
