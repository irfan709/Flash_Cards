import 'package:flash_cards/database/auth_helper.dart';
import 'package:flash_cards/provider/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends StateNotifier<AuthenticationState> {
  final AuthHelper authHelper;

  AuthProvider(this.authHelper) : super(AuthenticationState.initial());

  Future<void> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await authHelper.signUp(
        email: email,
        password: password,
      );
      state = state.copyWith(user: response.user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await authHelper.signIn(
        email: email,
        password: password,
      );
      state = state.copyWith(user: response.user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await authHelper.signOut();
      state = AuthenticationState.initial();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final authHelperProvider = Provider.autoDispose<AuthHelper>((ref) {
  final client = Supabase.instance.client;
  return AuthHelper(client: client);
});

final authStateProvider =
    StateNotifierProvider.autoDispose<AuthProvider, AuthenticationState>((ref) {
      final authHelper = ref.read(authHelperProvider);
      return AuthProvider(authHelper);
    });
