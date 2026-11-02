enum TicketStatus { open, inProgress, resolved }

class TicketEvent {
  const TicketEvent({required this.title, required this.at, this.note, this.byCustomer = false});

  final String title;
  final DateTime at;
  final String? note;
  final bool byCustomer;
}

class Ticket {
  const Ticket({
    required this.id,
    required this.subject,
    required this.category,
    required this.status,
    required this.createdAt,
    required this.events,
    this.description = '',
    this.followUpAt,
    this.preferredTime,
  });

  final String id;
  final String subject;
  final String category;
  final TicketStatus status;
  final DateTime createdAt;
  final String description;
  final DateTime? followUpAt;
  final String? preferredTime;

  /// Oldest first.
  final List<TicketEvent> events;

  DateTime get updatedAt => events.isEmpty ? createdAt : events.last.at;
  bool get isOpen => status != TicketStatus.resolved;

  Ticket copyWith({TicketStatus? status, List<TicketEvent>? events}) => Ticket(
    id: id,
    subject: subject,
    category: category,
    status: status ?? this.status,
    createdAt: createdAt,
    description: description,
    followUpAt: followUpAt,
    preferredTime: preferredTime,
    events: events ?? this.events,
  );
}
