import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ProgressIndicatorCard extends StatelessWidget {
  final int completedCount;
  final int totalCount;
  final String title;

  const ProgressIndicatorCard({
    super.key,
    required this.completedCount,
    required this.totalCount,
    this.title = 'Application Progress',
  });

  double get progressFraction {
    if (totalCount == 0) return 0.0;
    return (completedCount / totalCount).clamp(0.0, 1.0);
  }

  int get progressPercent {
    return (progressFraction * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
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
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
              Text(
                totalCount == 0 ? '–' : '$progressPercent%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressFraction,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.secondaryTeal,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            totalCount == 0
                ? 'No requirements yet. Add them from the checklist.'
                : '$completedCount of $totalCount requirements completed',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
