import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/formatters.dart';
import 'account_providers.dart';

enum AuthStage { signedOut, codeSent, signedIn }

class AuthState {
  const AuthState({this.stage = AuthStage.signedOut, this.phone = ''});

  final AuthStage stage;

  /// E.164 number the code was sent to.
  final String phone;

  bool get isSignedIn => stage == AuthStage.signedIn;
}

final authProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  /// [identifier] is a Kenyan mobile number or an account number. For an
  /// account number the code goes to the phone registered on the account.
  Future<void> sendCode(String identifier) async {
    final phone = normaliseKePhone(identifier) ?? ref.read(customerProvider).primaryPhone;
    await ref.read(accountRepositoryProvider).sendOtp(phone);
    state = AuthState(stage: AuthStage.codeSent, phone: phone);
  }

  Future<void> resendCode() => ref.read(accountRepositoryProvider).sendOtp(state.phone);

  Future<bool> verify(String code) async {
    final ok = await ref.read(accountRepositoryProvider).verifyOtp(state.phone, code);
    if (ok) state = AuthState(stage: AuthStage.signedIn, phone: state.phone);
    return ok;
  }

  void signOut() => state = const AuthState();
}
