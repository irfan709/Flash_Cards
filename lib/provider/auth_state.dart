import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticationState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthenticationState({
    required this.user,
    required this.isLoading,
    this.error,
  });

  AuthenticationState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthenticationState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  factory AuthenticationState.initial() {
    return AuthenticationState(user: null, isLoading: false, error: null);
  }
}
