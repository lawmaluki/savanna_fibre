import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/mock_data.dart';
import '../data/models/billing.dart';
import '../data/models/customer.dart';
import '../data/models/plan.dart';
import '../data/models/ticket.dart';
import '../data/repositories/account_repository.dart';

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

final accountRepositoryProvider = Provider<AccountRepository>((ref) => MockAccountRepository());

// ---------------------------------------------------------------------------
// Customer
// ---------------------------------------------------------------------------

final customerProvider = NotifierProvider<CustomerController, Customer>(CustomerController.new);

class CustomerController extends Notifier<Customer> {
  @override
  Customer build() => MockData.customer;

  void updateContact({required String email, String? secondaryPhone}) =>
      state = state.copyWith(email: email, secondaryPhone: secondaryPhone, clearSecondaryPhone: secondaryPhone == null);

  void setPaymentReminders(bool value) => state = state.copyWith(paymentReminders: value);
  void setServiceAlerts(bool value) => state = state.copyWith(serviceAlerts: value);
}

// ---------------------------------------------------------------------------
// Plans, connection and add-ons
// ---------------------------------------------------------------------------

final plansProvider = Provider<List<Plan>>((ref) => MockData.plans);

/// Paid plans a customer can renew onto. The complimentary plan is
/// welcome-only.
final renewablePlansProvider = Provider<List<Plan>>((ref) => ref.watch(plansProvider).where((p) => !p.isFree).toList());

final addonsProvider = Provider<List<Addon>>((ref) => MockData.addons);

final connectionProvider = NotifierProvider<ConnectionController, Connection>(ConnectionController.new);

class ConnectionController extends Notifier<Connection> {
  @override
  Connection build() => MockData.connection;

  Future<void> renew(Plan plan, PaymentMethod method) async {
    final wallet = ref.read(walletProvider.notifier);
    if (method == PaymentMethod.wallet) wallet.ensureCanPay(plan.priceKes);

    await ref.read(accountRepositoryProvider).renewConnection(connectionId: state.id, planId: plan.id, method: method);

    final now = DateTime.now();
    // Same plan, still running: extend from the current end date.
    final start = state.plan.id == plan.id && state.expiresAt.isAfter(now) ? state.expiresAt : now;
    final end = start.add(Duration(days: plan.validityDays));

    wallet.charge(title: '${plan.name} plan renewal', amount: plan.priceKes, method: method);
    ref
        .read(invoicesProvider.notifier)
        .add(
          Invoice(
            id: 'INV-${now.millisecondsSinceEpoch.toString().substring(7)}',
            title: '${plan.name} plan',
            issuedAt: now,
            periodStart: start,
            periodEnd: end,
            lines: [InvoiceLine('${plan.name} ${plan.speedMbps} Mbps, ${plan.validityDays} days', plan.priceKes)],
            status: InvoiceStatus.paid,
            paidWith: method,
          ),
        );
    state = state.copyWith(plan: plan, expiresAt: end);
  }
}

final activeAddonsProvider = NotifierProvider<ActiveAddonsController, Set<String>>(ActiveAddonsController.new);

class ActiveAddonsController extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  Future<void> purchase(Addon addon, PaymentMethod method) async {
    final wallet = ref.read(walletProvider.notifier);
    if (method == PaymentMethod.wallet) wallet.ensureCanPay(addon.priceKes);
    await ref.read(accountRepositoryProvider).purchaseAddon(addonId: addon.id, method: method);
    wallet.charge(title: addon.name, amount: addon.priceKes, method: method);
    state = {...state, addon.id};
  }
}

// ---------------------------------------------------------------------------
// Wallet and billing
// ---------------------------------------------------------------------------

final walletProvider = NotifierProvider<WalletController, WalletState>(WalletController.new);

class WalletController extends Notifier<WalletState> {
  @override
  WalletState build() => MockData.wallet;

  Future<void> topUp(double amount, String phone) async {
    final receipt = await ref.read(accountRepositoryProvider).requestMpesaPayment(amount: amount, phone: phone);
    state = state.copyWith(
      balance: state.balance + amount,
      transactions: [
        WalletTransaction(
          id: receipt,
          title: 'Wallet top-up',
          amount: amount,
          at: DateTime.now(),
          method: PaymentMethod.mpesa,
          reference: receipt,
        ),
        ...state.transactions,
      ],
    );
  }

  void ensureCanPay(double amount) {
    if (state.balance < amount) throw const InsufficientFundsException();
  }

  /// Records a payment. Wallet payments reduce the balance; M-Pesa payments
  /// are logged for history only.
  void charge({required String title, required double amount, required PaymentMethod method}) {
    if (method == PaymentMethod.wallet) ensureCanPay(amount);
    state = state.copyWith(
      balance: method == PaymentMethod.wallet ? state.balance - amount : state.balance,
      transactions: [
        WalletTransaction(
          id: 'TX${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          amount: -amount,
          at: DateTime.now(),
          method: method,
        ),
        ...state.transactions,
      ],
    );
  }
}

final invoicesProvider = NotifierProvider<InvoicesController, List<Invoice>>(InvoicesController.new);

class InvoicesController extends Notifier<List<Invoice>> {
  @override
  List<Invoice> build() => MockData.invoices;

  void add(Invoice invoice) => state = [invoice, ...state];
}

// ---------------------------------------------------------------------------
// Support tickets
// ---------------------------------------------------------------------------

final ticketsProvider = NotifierProvider<TicketsController, List<Ticket>>(TicketsController.new);

class TicketsController extends Notifier<List<Ticket>> {
  @override
  List<Ticket> build() => MockData.tickets;

  Future<Ticket> create({required String category, required String description, required String preferredTime}) async {
    final id = await ref.read(accountRepositoryProvider).createTicket(category: category, description: description);
    final now = DateTime.now();
    final ticket = Ticket(
      id: id,
      subject: category,
      category: category,
      status: TicketStatus.open,
      createdAt: now,
      description: description,
      preferredTime: preferredTime,
      events: [
        TicketEvent(title: 'Ticket opened', at: now, byCustomer: true),
        TicketEvent(title: 'Received by support', at: now, note: "We'll call you within 4 working hours."),
      ],
    );
    state = [ticket, ...state];
    return ticket;
  }

  Future<void> resolve(String id) async {
    await ref.read(accountRepositoryProvider).updateTicket(id);
    _update(
      id,
      (t) => t.copyWith(
        status: TicketStatus.resolved,
        events: [
          ...t.events,
          TicketEvent(title: 'Marked resolved by you', at: DateTime.now(), byCustomer: true),
        ],
      ),
    );
  }

  Future<void> addComment(String id, String text) async {
    await ref.read(accountRepositoryProvider).updateTicket(id);
    _update(
      id,
      (t) => t.copyWith(
        events: [
          ...t.events,
          TicketEvent(title: 'You added a comment', note: text, at: DateTime.now(), byCustomer: true),
        ],
      ),
    );
  }

  void _update(String id, Ticket Function(Ticket) change) =>
      state = [for (final t in state) t.id == id ? change(t) : t];
}

// ---------------------------------------------------------------------------
// App preferences
// ---------------------------------------------------------------------------

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setDark(bool dark) => state = dark ? ThemeMode.dark : ThemeMode.light;
}

final balanceHiddenProvider = NotifierProvider<BalanceHiddenController, bool>(BalanceHiddenController.new);

class BalanceHiddenController extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}
