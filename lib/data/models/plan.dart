class Plan {
  const Plan({
    required this.id,
    required this.name,
    required this.speedMbps,
    required this.priceKes,
    required this.validityDays,
    this.tagline = '',
    this.popular = false,
  });

  final String id;
  final String name;
  final int speedMbps;
  final double priceKes;
  final int validityDays;
  final String tagline;
  final bool popular;

  bool get isFree => priceKes == 0;
}

enum ConnectionStatus { active, expiringSoon, expired }

class Connection {
  const Connection({required this.id, required this.plan, required this.expiresAt});

  final String id;
  final Plan plan;
  final DateTime expiresAt;

  int daysLeft(DateTime now) {
    final hours = expiresAt.difference(now).inHours;
    return hours <= 0 ? 0 : (hours / 24).ceil();
  }

  ConnectionStatus status(DateTime now) {
    if (!expiresAt.isAfter(now)) return ConnectionStatus.expired;
    if (daysLeft(now) <= 3) return ConnectionStatus.expiringSoon;
    return ConnectionStatus.active;
  }

  Connection copyWith({Plan? plan, DateTime? expiresAt}) =>
      Connection(id: id, plan: plan ?? this.plan, expiresAt: expiresAt ?? this.expiresAt);
}

enum AddonBilling { monthly, oneOff }

class Addon {
  const Addon({
    required this.id,
    required this.name,
    required this.description,
    required this.priceKes,
    required this.billing,
    required this.confirmation,
  });

  final String id;
  final String name;
  final String description;
  final double priceKes;
  final AddonBilling billing;

  /// Shown after purchase.
  final String confirmation;
}
