import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/billing/billing_screen.dart';
import '../../features/billing/invoice_detail_screen.dart';
import '../../features/help/help_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/plans/addons_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/renew/renew_screen.dart';
import '../../features/tickets/create_ticket_screen.dart';
import '../../features/tickets/ticket_detail_screen.dart';
import '../../features/tickets/tickets_screen.dart';
import '../../features/wallet/top_up_screen.dart';
import '../../state/auth_controller.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ValueNotifier<AuthState>(ref.read(authProvider));
  ref.listen<AuthState>(authProvider, (_, next) => auth.value = next);
  ref.onDispose(auth.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/login',
    refreshListenable: auth,
    redirect: (context, state) {
      final stage = auth.value.stage;
      final loc = state.matchedLocation;
      final inAuthFlow = loc == '/login' || loc == '/otp';

      if (stage == AuthStage.signedIn) return inAuthFlow ? '/home' : null;
      if (loc == '/otp') return stage == AuthStage.codeSent ? null : '/login';
      return inAuthFlow ? null : '/login';
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/otp', builder: (context, state) => const OtpScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      // Everything else is pushed on top of home.
      GoRoute(path: '/billing', builder: (context, state) => const BillingScreen()),
      GoRoute(path: '/support', builder: (context, state) => const TicketsScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/renew', builder: (context, state) => const RenewScreen()),
      GoRoute(path: '/addons', builder: (context, state) => const AddonsScreen()),
      GoRoute(path: '/top-up', builder: (context, state) => const TopUpScreen()),
      GoRoute(
        path: '/invoice/:id',
        builder: (context, state) => InvoiceDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/tickets/new',
        builder: (context, state) => CreateTicketScreen(initialCategory: state.uri.queryParameters['category']),
      ),
      GoRoute(
        path: '/tickets/:id',
        builder: (context, state) => TicketDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(path: '/help', builder: (context, state) => const HelpScreen()),
    ],
  );
});
