import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_strings.dart';
import '../providers/ai_provider.dart';
import '../providers/deadline_provider.dart';
import '../providers/requirement_provider.dart';
import '../providers/scholarship_provider.dart';
import 'app_routes.dart';
import 'app_theme.dart';

class DossierApp extends StatelessWidget {
  const DossierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScholarshipProvider()),
        ChangeNotifierProvider(create: (_) => RequirementProvider()),
        ChangeNotifierProvider(create: (_) => DeadlineProvider()),
        ChangeNotifierProvider(create: (_) => AiProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
