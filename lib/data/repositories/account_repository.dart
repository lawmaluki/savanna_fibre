import 'dart:math';

import '../models/billing.dart';

/// Everything the app asks of the backend. Swap [MockAccountRepository] for
/// an HTTP implementation in `accountRepositoryProvider` when the API is ready.
abstract class AccountRepository {
  Future<void> sendOtp(String phone);
  Future<bool> verifyOtp(String phone, String code);

  /// Sends an M-Pesa STK push and resolves with the receipt number once the
  /// customer confirms on their phone.
  Future<String> requestMpesaPayment({required double amount, required String phone});

  Future<void> renewConnection({required String connectionId, required String planId, required PaymentMethod method});
  Future<void> purchaseAddon({required String addonId, required PaymentMethod method});
  Future<String> createTicket({required String category, required String description});
  Future<void> updateTicket(String ticketId);
}

class MockAccountRepository implements AccountRepository {
  final _random = Random();
  var _ticketSeq = 4010;

  Future<void> _latency([int ms = 900]) => Future.delayed(Duration(milliseconds: ms));

  @override
  Future<void> sendOtp(String phone) => _latency(800);

  @override
  Future<bool> verifyOtp(String phone, String code) async {
    await _latency(900);
    return code.length == 6;
  }

  @override
  Future<String> requestMpesaPayment({required double amount, required String phone}) async {
    await _latency(2600);
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ0123456789';
    return 'T${List.generate(9, (_) => chars[_random.nextInt(chars.length)]).join()}';
  }

  @override
  Future<void> renewConnection({required String connectionId, required String planId, required PaymentMethod method}) =>
      _latency(1200);

  @override
  Future<void> purchaseAddon({required String addonId, required PaymentMethod method}) => _latency(1000);

  @override
  Future<String> createTicket({required String category, required String description}) async {
    await _latency(1000);
    return 'INQ-${_ticketSeq++}';
  }

  @override
  Future<void> updateTicket(String ticketId) => _latency(500);
}
