import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/widgets/widgets.dart';
import '../../state/account_providers.dart';
import 'ticket_ui.dart';

class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key, this.initialCategory});

  final String? initialCategory;

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  static const _times = ['Morning', 'Afternoon', 'Evening', 'Any time'];

  final _description = TextEditingController();
  TicketCategory? _category;
  String _time = 'Any time';
  bool _photoAttached = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _category = TicketCategory.all.where((c) => c.id == widget.initialCategory).firstOrNull;
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  bool get _valid {
    if (_category == null) return false;
    // "Something else" needs a description to be actionable.
    return _category!.id != 'other' || _description.text.trim().length >= 10;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    final ticket = await ref
        .read(ticketsProvider.notifier)
        .create(category: _category!.label, description: _description.text.trim(), preferredTime: _time);
    if (!mounted) return;
    context.pushReplacement('/tickets/${ticket.id}');
    showSfSnack(context, 'Ticket ${ticket.id} sent. We\'ll call you soon.');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    final t = context.text;

    return Scaffold(
      appBar: const SfAppBar(title: 'Report an issue'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Insets.page, Insets.sm, Insets.page, Insets.xxl),
        children: [
          Text('What do you need help with?', style: t.titleLarge),
          const Gap(Insets.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - Insets.sm) / 2;
              return Wrap(
                spacing: Insets.sm,
                runSpacing: Insets.sm,
                children: [
                  for (final category in TicketCategory.all)
                    SizedBox(
                      width: width,
                      child: _CategoryTile(
                        category: category,
                        selected: _category?.id == category.id,
                        onTap: () => setState(() => _category = category),
                      ),
                    ),
                ],
              );
            },
          ),
          const Gap(Insets.xxl),
          Text('Tell us more', style: t.titleLarge),
          const Gap(Insets.xs),
          Text(_category?.prompt ?? 'Pick a topic above and we\'ll suggest what to include.', style: t.bodySmall),
          const Gap(Insets.md),
          TextField(
            controller: _description,
            minLines: 4,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: _category?.id == 'other'
                  ? 'Describe what you need'
                  : 'Optional, but it helps us fix things faster',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const Gap(Insets.md),
          SfCard(
            onTap: () => setState(() => _photoAttached = !_photoAttached),
            child: Row(
              children: [
                SfIconBox(
                  icon: _photoAttached ? PhosphorIconsBold.check : PhosphorIconsRegular.camera,
                  size: 40,
                  iconSize: 20,
                  radius: 12,
                  background: _photoAttached ? p.successSoft : p.surfaceAlt,
                  foreground: _photoAttached ? p.success : p.inkMuted,
                ),
                const Gap(Insets.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_photoAttached ? 'Photo attached' : 'Add a photo', style: t.titleSmall),
                      Text(
                        _photoAttached ? 'Tap to remove' : 'A photo of the router lights helps our technicians.',
                        style: t.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(Insets.xxl),
          Text('Best time to call you', style: t.titleLarge),
          const Gap(Insets.md),
          Wrap(
            spacing: Insets.sm,
            runSpacing: Insets.sm,
            children: [
              for (final time in _times)
                SfChoicePill(label: time, selected: _time == time, onTap: () => setState(() => _time = time)),
            ],
          ),
        ].staggered(),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Insets.page, Insets.sm, Insets.page, Insets.md),
          child: SfButton(label: 'Send ticket', loading: _busy, onPressed: _valid ? _submit : null),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.selected, required this.onTap});

  final TicketCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    return Semantics(
      selected: selected,
      button: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: selected ? p.accentSoft : p.surface,
          borderRadius: BorderRadius.circular(Radii.md + 2),
          border: Border.all(color: selected ? p.accent : p.line, width: selected ? 2 : 1),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(Radii.md + 2),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(selected ? 13 : 14),
              child: Row(
                children: [
                  Icon(category.icon, size: 22, color: selected ? p.accentDeep : p.ink),
                  const Gap(Insets.sm + 2),
                  Expanded(child: Text(category.label, style: context.text.titleSmall, maxLines: 2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
