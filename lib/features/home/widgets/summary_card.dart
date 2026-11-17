import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color accentColor;

  const SummaryCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    this.accentColor = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$count',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                    fontSize: 22,
                  ),
                ),
                Icon(icon, size: 20, color: accentColor),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
