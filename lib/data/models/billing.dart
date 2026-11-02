enum PaymentMethod { wallet, mpesa }

extension PaymentMethodLabel on PaymentMethod {
  String get label => switch (this) {
    PaymentMethod.wallet => 'Wallet',
    PaymentMethod.mpesa => 'M-Pesa',
  };
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.at,
    required this.method,
    this.reference,
  });

  final String id;
  final String title;

  /// Positive for money in, negative for money out.
  final double amount;
  final DateTime at;
  final PaymentMethod method;
  final String? reference;

  bool get isCredit => amount > 0;
}

class WalletState {
  const WalletState({required this.balance, required this.transactions});

  final double balance;
  final List<WalletTransaction> transactions;

  WalletState copyWith({double? balance, List<WalletTransaction>? transactions}) =>
      WalletState(balance: balance ?? this.balance, transactions: transactions ?? this.transactions);
}

class InsufficientFundsException implements Exception {
  const InsufficientFundsException();
}

enum InvoiceStatus { paid, due }

class InvoiceLine {
  const InvoiceLine(this.description, this.amount);

  final String description;
  final double amount;
}

class Invoice {
  const Invoice({
    required this.id,
    required this.title,
    required this.issuedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.lines,
    required this.status,
    this.paidWith,
  });

  final String id;
  final String title;
  final DateTime issuedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<InvoiceLine> lines;
  final InvoiceStatus status;
  final PaymentMethod? paidWith;

  double get total => lines.fold(0, (sum, line) => sum + line.amount);
}
