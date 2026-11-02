import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savanna_fibre/core/theme/app_colors.dart';
import 'package:savanna_fibre/features/profile/profile_screen.dart';
import 'package:savanna_fibre/state/account_providers.dart';

// Use local Material typography so layout checks do not fetch Google Fonts.
Widget profileApp(
  ProviderContainer container, {
  bool dark = false,
  double textScale = 1,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: ThemeData(
        brightness: dark ? Brightness.dark : Brightness.light,
        extensions: [dark ? SfPalette.dark : SfPalette.light],
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: true,
        ),
        child: child!,
      ),
      home: const ProfileScreen(),
    ),
  );
}

void main() {
  for (final dark in [false, true]) {
    testWidgets(
      'profile scrolls without overflow at 320px with large text, dark=$dark',
      (tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(
          profileApp(container, dark: dark, textScale: 2),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.scrollUntilVisible(
          find.text('Sign out'),
          350,
          maxScrolls: 40,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Sign out').hitTestable(), findsOneWidget);
      },
    );
  }

  testWidgets(
    'contact editing, preferences and sign-out cancellation remain usable',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(profileApp(container));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).first,
        'updated@example.com',
      );
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(container.read(customerProvider).email, 'updated@example.com');
      expect(find.text('updated@example.com'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Payment reminders'), 300);
      await tester.tap(find.text('Payment reminders'));
      await tester.pumpAndSettle();
      expect(container.read(customerProvider).paymentReminders, isFalse);

      await tester.scrollUntilVisible(find.text('Service alerts'), 200);
      await tester.tap(find.text('Service alerts'));
      await tester.pumpAndSettle();
      expect(container.read(customerProvider).serviceAlerts, isFalse);

      await tester.scrollUntilVisible(find.text('Dark mode'), 200);
      await tester.tap(find.text('Dark mode'));
      await tester.pumpAndSettle();
      expect(container.read(themeModeProvider), ThemeMode.dark);

      await tester.scrollUntilVisible(find.text('Sign out'), 200);
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(find.text('Sign out?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Sign out?'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
