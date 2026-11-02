import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/widgets/widgets.dart';
import '../../data/models/ticket.dart';

class TicketStatusChip extends StatelessWidget {
  const TicketStatusChip({super.key, required this.status});

  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, tone) = switch (status) {
      TicketStatus.open => ('Open', SfTone.accent),
      TicketStatus.inProgress => ('In progress', SfTone.warning),
      TicketStatus.resolved => ('Resolved', SfTone.success),
    };
    return SfStatusChip(label: label, tone: tone);
  }
}

class TicketCategory {
  const TicketCategory(this.id, this.label, this.icon, this.prompt);

  final String id;
  final String label;
  final IconData icon;

  /// Helps the customer write a useful description.
  final String prompt;

  static const all = <TicketCategory>[
    TicketCategory(
      'no_internet',
      'No internet',
      PhosphorIconsRegular.wifiSlash,
      'When did it stop? Is any light on the router red?',
    ),
    TicketCategory(
      'slow',
      'Slow speed',
      PhosphorIconsRegular.gauge,
      'Is it slow on every device, or only on Wi-Fi far from the router?',
    ),
    TicketCategory(
      'billing',
      'Billing or payment',
      PhosphorIconsRegular.receipt,
      'Add the M-Pesa code if a payment is missing.',
    ),
    TicketCategory(
      'router',
      'Router or Wi-Fi',
      PhosphorIconsRegular.wifiHigh,
      'Tell us what the router is doing, or what you want changed.',
    ),
    TicketCategory('moving', 'Moving house', PhosphorIconsRegular.truck, 'Where are you moving to, and when?'),
    TicketCategory('other', 'Something else', PhosphorIconsRegular.chatCircleDots, 'Tell us what you need.'),
  ];
}
