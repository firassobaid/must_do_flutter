import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 80,
                color: AppColors.primary,
              ),
            )
                .animate(
                  onComplete: (controller) {
                    if (mounted) {
                      context.go('/');
                    }
                  },
                )
                .fadeIn(duration: 800.ms, curve: Curves.easeIn)
                .then(delay: 1500.ms)
                .fadeOut(duration: 800.ms, curve: Curves.easeOut),
            const SizedBox(height: 24),
            Text(
              'Must Do',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
          ],
        ),
      ),
    );
  }
}
