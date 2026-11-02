class ServiceAddress {
  const ServiceAddress({
    required this.serviceArea,
    required this.branch,
    required this.latitude,
    required this.longitude,
    this.road,
    this.landmark,
    this.unit,
  });

  final String serviceArea;
  final String branch;
  final double latitude;
  final double longitude;
  final String? road;
  final String? landmark;
  final String? unit;
}

class Customer {
  const Customer({
    required this.name,
    required this.accountNumber,
    required this.username,
    required this.primaryPhone,
    required this.email,
    required this.customerType,
    required this.category,
    required this.isActive,
    required this.activatedAt,
    required this.paymentReminders,
    required this.serviceAlerts,
    required this.address,
    this.secondaryPhone,
  });

  final String name;
  final String accountNumber;
  final String username;
  final String primaryPhone;
  final String? secondaryPhone;
  final String email;
  final String customerType;
  final String category;
  final bool isActive;
  final DateTime activatedAt;

  /// "Dunning" in the billing system: SMS reminders before a plan lapses.
  final bool paymentReminders;

  /// "Automatic notification" in the billing system.
  final bool serviceAlerts;
  final ServiceAddress address;

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  String get initials =>
      name.trim().split(RegExp(r'\s+')).take(2).map((part) => part.isEmpty ? '' : part[0]).join().toUpperCase();

  Customer copyWith({
    String? email,
    String? secondaryPhone,
    bool clearSecondaryPhone = false,
    bool? paymentReminders,
    bool? serviceAlerts,
  }) {
    return Customer(
      name: name,
      accountNumber: accountNumber,
      username: username,
      primaryPhone: primaryPhone,
      secondaryPhone: clearSecondaryPhone ? null : secondaryPhone ?? this.secondaryPhone,
      email: email ?? this.email,
      customerType: customerType,
      category: category,
      isActive: isActive,
      activatedAt: activatedAt,
      paymentReminders: paymentReminders ?? this.paymentReminders,
      serviceAlerts: serviceAlerts ?? this.serviceAlerts,
      address: address,
    );
  }
}
