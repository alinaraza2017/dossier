import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/shared_design_widgets.dart';
import '../../../data/models/scholarship.dart';

class ScholarshipCard extends StatelessWidget {
  final Scholarship scholarship;
  final int completedCount;
  final int totalCount;
  final VoidCallback onTap;

  const ScholarshipCard({
    super.key,
    required this.scholarship,
    required this.completedCount,
    required this.totalCount,
    required this.onTap,
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
    final deadlineDate = scholarship.deadlineDateTime;
    final daysRemaining = AppDateUtils.daysRemaining(deadlineDate);

    // Document chip styling
    Color chipBg = AppColors.chipLaterBg;
    Color chipText = AppColors.chipLaterText;
    String chipLabel = '$daysRemaining days left';

    if (scholarship.isSubmitted) {
      chipBg = AppColors.chipSubmittedBg;
      chipText = AppColors.chipSubmittedText;
      chipLabel = 'Submitted';
    } else if (daysRemaining < 0) {
      chipBg = AppColors.chipOverdueBg;
      chipText = AppColors.chipOverdueText;
      chipLabel = 'Overdue';
    } else if (daysRemaining == 0) {
      chipBg = AppColors.chipUrgentBg;
      chipText = AppColors.chipUrgentText;
      chipLabel = 'Due today';
    } else if (daysRemaining <= 7) {
      chipBg = AppColors.chipUrgentBg;
      chipText = AppColors.chipUrgentText;
      chipLabel = '$daysRemaining days left';
    } else if (daysRemaining <= 21) {
      chipBg = AppColors.chipDueSoonBg;
      chipText = AppColors.chipDueSoonText;
      chipLabel = '$daysRemaining days left';
    }

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Name and Days Left Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  scholarship.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  chipLabel,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: chipText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),

          // Row 2: Country · Due Date
          Text(
            '${scholarship.country.isNotEmpty ? "${scholarship.country} · " : ""}Due ${AppDateUtils.formatDisplay(deadlineDate)}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 12),

          // Row 3: Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressFraction,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.secondaryTeal,
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Row 4: Requirements count and Percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                totalCount == 0
                    ? 'No requirements yet'
                    : '$completedCount of $totalCount requirements',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                totalCount == 0 ? '' : '$progressPercent%',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
