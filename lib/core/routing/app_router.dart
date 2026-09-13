import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/authentication/presentation/controllers/auth_controller.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/tasks/presentation/screens/home_screen.dart';
import '../../features/tasks/presentation/screens/task_list_detail_screen.dart';
import '../../features/sharing/presentation/screens/invitations_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';

part 'app_router.g.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  final refreshListenable = _RouterRefreshNotifier();
  ref.onDispose(refreshListenable.dispose);

  ref.listen(authStateChangesProvider, (previous, next) {
    if (previous?.valueOrNull != next.valueOrNull) {
      refreshListenable.refresh();
    }
  });

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);
      final matchedLocation = state.matchedLocation;

      // Always allow the splash screen to finish its animation
      if (matchedLocation == '/splash') return null;

      // Wait for the auth state to resolve before redirecting elsewhere
      if (authState.isLoading) return null;

      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = matchedLocation == '/login' || matchedLocation == '/register';

      if (!isLoggedIn) {
        return isAuthRoute ? null : '/login';
      }

      if (isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/invitations',
        builder: (context, state) => const InvitationsScreen(),
      ),
      GoRoute(
        path: '/list/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TaskListDetailScreen(listId: id);
        },
      ),
    ],
  );
}
