import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/widgets/widgets.dart';
import '../../data/models/ticket.dart';
import '../../state/account_providers.dart';
import 'ticket_ui.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  bool _resolving = false;

  Future<void> _resolve() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mark as resolved?'),
        content: const Text("We'll close this ticket. You can open a new one any time."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Keep open')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: dialogContext.sf.accentDeep),
            child: const Text('Mark resolved'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _resolving = true);
    await ref.read(ticketsProvider.notifier).resolve(widget.id);
    if (!mounted) return;
    setState(() => _resolving = false);
    showSfSnack(context, 'Ticket marked resolved');
  }

  Future<void> _comment() async {
    final sent = await showSfSheet<bool>(context, builder: (_) => _CommentSheet(ticketId: widget.id));
    if (sent == true && mounted) showSfSnack(context, 'Comment added');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    final ticket = ref.watch(ticketsProvider).where((t) => t.id == widget.id).firstOrNull;

    if (ticket == null) {
      return const Scaffold(
        appBar: SfAppBar(title: 'Ticket'),
        body: SfEmptyState(
          icon: PhosphorIconsRegular.lifebuoy,
          title: 'Ticket not found',
          message: 'It may have been closed or merged with another ticket.',
        ),
      );
    }

    return Scaffold(
      appBar: SfAppBar(title: ticket.id),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Insets.page, Insets.sm, Insets.page, Insets.xxl),
        children: [
          Text(ticket.subject, style: context.text.headlineMedium),
          const Gap(Insets.sm + 2),
          Wrap(
            spacing: Insets.sm,
            children: [
              TicketStatusChip(status: ticket.status),
              SfStatusChip(label: ticket.category, dot: false),
            ],
          ),
          const Gap(Insets.xl),
          SfGroup(
            title: 'Details',
            children: [
              SfInfoRow(label: 'Opened', value: fmtDateTime(ticket.createdAt)),
              if (ticket.followUpAt != null) SfInfoRow(label: 'Follow-up call', value: fmtDateTime(ticket.followUpAt!)),
              if (ticket.preferredTime != null) SfInfoRow(label: 'Best time to call', value: ticket.preferredTime!),
            ],
          ),
          if (ticket.description.isNotEmpty) ...[
            const Gap(Insets.xl),
            SfGroup(
              title: 'Description',
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(ticket.description, style: context.text.bodyMedium),
                  ),
                ),
              ],
            ),
          ],
          const Gap(Insets.xl),
          Padding(
            padding: const EdgeInsets.only(left: Insets.xs, bottom: Insets.md),
            child: Text('Activity', style: context.text.labelLarge!.copyWith(color: p.inkMuted)),
          ),
          _Timeline(events: ticket.events.reversed.toList()),
        ].staggered(),
      ),
      bottomNavigationBar: ticket.isOpen
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Insets.page, Insets.sm, Insets.page, Insets.md),
                child: Row(
                  children: [
                    Expanded(
                      child: SfButton(
                        label: 'Add comment',
                        variant: SfButtonVariant.ghost,
                        onPressed: _resolving ? null : _comment,
                      ),
                    ),
                    const Gap(Insets.sm + 2),
                    Expanded(
                      child: SfButton(label: 'Mark resolved', loading: _resolving, onPressed: _resolve),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.events});

  /// Newest first.
  final List<TicketEvent> events;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    return Column(
      children: [
        for (var i = 0; i < events.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 20,
                  child: Column(
                    children: [
                      const Gap(4),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == 0 ? p.accent : p.surface,
                          border: Border.all(color: i == 0 ? p.accent : p.line, width: 2),
                        ),
                      ),
                      if (i < events.length - 1) Expanded(child: Container(width: 2, color: p.line)),
                    ],
                  ),
                ),
                const Gap(Insets.md),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: Insets.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(events[i].title, style: context.text.titleSmall),
                        const Gap(2),
                        Text(fmtDateTime(events[i].at), style: context.text.bodySmall),
                        if (events[i].note != null) ...[
                          const Gap(Insets.sm),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(Insets.md),
                            decoration: BoxDecoration(
                              color: events[i].byCustomer ? p.accentSoft : p.surface,
                              borderRadius: BorderRadius.circular(Radii.md),
                              border: events[i].byCustomer ? null : Border.all(color: p.line),
                            ),
                            child: Text(events[i].note!, style: context.text.bodyMedium),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CommentSheet extends ConsumerStatefulWidget {
  const _CommentSheet({required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends ConsumerState<_CommentSheet> {
  final _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _busy = true);
    await ref.read(ticketsProvider.notifier).addComment(widget.ticketId, _controller.text.trim());
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add a comment', style: context.text.headlineSmall),
        const Gap(Insets.lg),
        TextField(
          controller: _controller,
          autofocus: true,
          minLines: 3,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Anything new our team should know?'),
          onChanged: (_) => setState(() {}),
        ),
        const Gap(Insets.lg),
        SfButton(label: 'Send comment', loading: _busy, onPressed: _controller.text.trim().isEmpty ? null : _send),
      ],
    );
  }
}
