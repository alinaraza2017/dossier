import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/scholarship.dart';

class UpcomingDeadlineCard extends StatelessWidget {
  final Scholarship scholarship;
  final VoidCallback onTap;

  const UpcomingDeadlineCard({
    super.key,
    required this.scholarship,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deadlineDate = scholarship.deadlineDateTime;
    final category = AppDateUtils.classifyDeadline(
      deadline: deadlineDate,
      status: scholarship.status,
    );
    final daysText = AppDateUtils.formatDaysRemaining(deadlineDate);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.lightBlueSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.alarm,
                color: AppColors.primaryBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scholarship.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Due: ${AppDateUtils.formatDisplay(deadlineDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusChip.fromDeadlineCategory(category, customLabel: daysText),
          ],
        ),
      ),
    );
  }
}
