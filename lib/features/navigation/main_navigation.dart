import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../home/home_screen.dart';
import '../deadlines/deadlines_screen.dart';
import '../ai_assistant/ai_assistant_screen.dart';
import '../settings/settings_screen.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    DeadlinesScreen(),
    AiAssistantScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardSurface : AppColors.cardSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
            _buildNavItem(1, Icons.alarm_outlined, Icons.alarm_rounded, 'Deadlines'),
            _buildNavItem(2, Icons.auto_awesome_outlined, Icons.auto_awesome_rounded, 'AI Assistant'),
            _buildNavItem(3, Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData filledIcon, String label) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.darkPrimary.withValues(alpha: 0.15) : AppColors.lightBlueSurface)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? filledIcon : outlineIcon,
                color: isSelected
                    ? (isDark ? AppColors.darkPrimary : AppColors.primaryBlue)
                    : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? (isDark ? AppColors.darkPrimary : AppColors.primaryBlue)
                    : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
