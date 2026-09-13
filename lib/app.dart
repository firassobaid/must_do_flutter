import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'features/authentication/presentation/controllers/auth_controller.dart';

class MustDoApp extends ConsumerWidget {
  const MustDoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    // Initialize notification service
    ref.watch(notificationServiceProvider);

    // Listen to auth changes to update FCM token
    ref.listen(authStateChangesProvider, (previous, next) async {
      final user = next.value;
      if (user == null) return;
      // Best effort: a failed token sync must never surface as an app level crash.
      try {
        final token = await ref.read(notificationServiceProvider.notifier).getToken();
        if (token != null) {
          await ref.read(authRepositoryProvider).updateFCMToken(user.uid, token);
        }
      } catch (e) {
        debugPrint('Failed to sync FCM token: $e');
      }
    });

    return MaterialApp.router(
      title: 'Must Do Tasks',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
