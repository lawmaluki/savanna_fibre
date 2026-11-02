import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savanna_fibre/core/utils/formatters.dart';
import 'package:savanna_fibre/data/models/plan.dart';
import 'package:savanna_fibre/state/account_providers.dart';
import 'package:savanna_fibre/data/models/billing.dart';

void main() {
  group('formatters', () {
    test('normalises Kenyan mobile numbers', () {
      expect(normaliseKePhone('0734 222 990'), '+254734222990');
      expect(normaliseKePhone('+254734222990'), '+254734222990');
      expect(normaliseKePhone('734222990'), '+254734222990');
      expect(normaliseKePhone('12345'), isNull);
    });

    test('formats money', () {
      expect(kes(2500), 'KES 2,500');
      expect(kes(0, cents: true), 'KES 0.00');
    });
  });

  group('connection', () {
    test('expired plan has zero days left', () {
      const plan = Plan(id: 'p', name: 'P', speedMbps: 10, priceKes: 1, validityDays: 30);
      final c = Connection(id: 'c', plan: plan, expiresAt: DateTime(2025, 1, 1));
      expect(c.daysLeft(DateTime(2025, 2, 1)), 0);
      expect(c.status(DateTime(2025, 2, 1)), ConnectionStatus.expired);
    });
  });

  group('wallet', () {
    test('wallet payment fails when balance is too low', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(
        () => container.read(walletProvider.notifier).charge(title: 'x', amount: 100, method: PaymentMethod.wallet),
        throwsA(isA<InsufficientFundsException>()),
      );
    });

    test('M-Pesa payment is logged without touching the balance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(walletProvider.notifier).charge(title: 'x', amount: 100, method: PaymentMethod.mpesa);
      final wallet = container.read(walletProvider);
      expect(wallet.balance, 0);
      expect(wallet.transactions.single.amount, -100);
    });
  });
}
