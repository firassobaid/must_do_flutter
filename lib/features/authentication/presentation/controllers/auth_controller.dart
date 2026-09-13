import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/use_cases/sign_in_with_google.dart';

part 'auth_controller.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl();
}

@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

@riverpod
class AuthController extends _$AuthController {
  bool _disposed = false;

  @override
  FutureOr<void> build() {
    // Initial state is idle
    _disposed = false;
    ref.onDispose(() => _disposed = true);
  }

  /// Runs an auth action with loading/error state around it.
  ///
  /// The result is only written back if this provider is still alive. A
  /// successful auth action changes the Firebase auth state, which navigates
  /// away from the screen that triggered it, auto-disposing this provider
  /// mid-flight. Assigning state after that point completes an internal future
  /// that disposal already completed, throwing "Future already completed".
  Future<void> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(action);
    if (_disposed) return;
    state = result;
  }

  Future<void> signInWithGoogle() {
    return _run(() async {
      final useCase = SignInWithGoogle(ref.read(authRepositoryProvider));
      await useCase();
    });
  }

  Future<void> signUpWithEmailAndPassword(String email, String password, String displayName) {
    return _run(() =>
      ref.read(authRepositoryProvider).signUpWithEmailAndPassword(email, password, displayName)
    );
  }

  Future<void> signInWithEmailAndPassword(String email, String password) {
    return _run(() =>
      ref.read(authRepositoryProvider).signInWithEmailAndPassword(email, password)
    );
  }

  Future<void> signOut() {
    return _run(() => ref.read(authRepositoryProvider).signOut());
  }
}
