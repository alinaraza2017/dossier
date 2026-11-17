import 'package:flutter/material.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/navigation/main_navigation.dart';
import '../features/applications/add_application_screen.dart';
import '../features/applications/application_details_screen.dart';
import '../features/requirements/requirements_screen.dart';
import '../features/ai_assistant/ai_assistant_screen.dart';
import '../features/settings/settings_screen.dart';
import '../data/models/scholarship.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String addApplication = '/add-application';
  static const String applicationDetails = '/application-details';
  static const String requirements = '/requirements';
  static const String aiAssistant = '/ai-assistant';
  static const String settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case home:
        final initialIndex = settings.arguments as int? ?? 0;
        return MaterialPageRoute(
          builder: (_) => MainNavigation(initialIndex: initialIndex),
        );

      case addApplication:
        final scholarship = settings.arguments as Scholarship?;
        return MaterialPageRoute(
          builder: (_) => AddApplicationScreen(scholarshipToEdit: scholarship),
        );

      case applicationDetails:
        final scholarshipId = settings.arguments?.toString() ?? '';
        return MaterialPageRoute(
          builder: (_) =>
              ApplicationDetailsScreen(scholarshipId: scholarshipId),
        );

      case requirements:
        final scholarshipId = settings.arguments?.toString() ?? '';
        return MaterialPageRoute(
          builder: (_) =>
              RequirementsScreen(scholarshipId: scholarshipId),
        );

      case aiAssistant:
        final scholarshipId = settings.arguments?.toString();
        return MaterialPageRoute(
          builder: (_) => AiAssistantScreen(
            initialTargetScholarshipId: scholarshipId,
          ),
        );

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
