import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/bootstrap/demo_bootstrap.dart';
import '../data/mock_auth_repository.dart';
import '../models/auth_user.dart';

class AuthState {
  const AuthState({
    this.currentUser,
    this.isLoading = false,
    this.errorMessage,
  });

  final AuthUser? currentUser;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => currentUser != null;

  AuthState copyWith({
    AuthUser? currentUser,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthController extends Notifier<AuthState> {
  late final MockAuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.read(mockAuthRepositoryProvider);
    return const AuthState();
  }

  Future<bool> login({
    required String id,
    required String password,
  }) async {
    // Start demo bootstrap in background to reduce post-login wait.
    unawaited(DemoBootstrap.ensureInitialized());
    state = state.copyWith(isLoading: true, clearError: true);

    final AuthUser? user = await _repository.login(
      idInput: id,
      passwordInput: password,
    );

    if (user == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'invalid_credentials',
      );
      return false;
    }

    state = AuthState(currentUser: user);
    return true;
  }

  /// Signs in as a demo user by id (no password). Used by the role-entry screen.
  Future<bool> loginAsDemoUser(int id) async {
    unawaited(DemoBootstrap.ensureInitialized());
    state = state.copyWith(isLoading: true, clearError: true);
    final AuthUser? user = _repository.getUserById(id);
    if (user == null) {
      state = state.copyWith(isLoading: false);
      return false;
    }
    state = AuthState(currentUser: user);
    return true;
  }

  void logout() {
    state = const AuthState();
  }
}

final Provider<MockAuthRepository> mockAuthRepositoryProvider =
    Provider<MockAuthRepository>((ref) => MockAuthRepository());

final NotifierProvider<AuthController, AuthState> authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
