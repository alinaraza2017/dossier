import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/scholarship_provider.dart';
import '../../services/local_settings_service.dart';
import '../../services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 1. Initialize local settings
      await LocalSettingsService.instance.init();

      // 2. Initialize notification service
      await NotificationService.instance.initialize(
        onSelect: (scholarshipId) {
          if (mounted) {
            Navigator.of(
              context,
            ).pushNamed(AppRoutes.applicationDetails, arguments: scholarshipId);
          }
        },
      );

      // 3. Preload scholarships
      if (mounted) {
        await context.read<ScholarshipProvider>().loadScholarships();
      }

      // Small delay for calm visual branding
      await Future.delayed(const Duration(milliseconds: 1200));

      if (!mounted) return;

      final hasCompleted = LocalSettingsService.instance
          .isOnboardingCompleted();
      if (hasCompleted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      }
    } catch (e) {
      debugPrint('Initialization error in Splash: $e');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.lightBlueSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.school_rounded,
                      size: 48,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.appName,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.appTagline,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
