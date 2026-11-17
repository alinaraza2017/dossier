import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/date_utils.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color backgroundColor;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    this.icon,
  });

  /// Factory constructor to create a chip from a DeadlineCategory.
  factory StatusChip.fromDeadlineCategory(
    DeadlineCategory category, {
    String? customLabel,
  }) {
    switch (category) {
      case DeadlineCategory.urgent:
        return StatusChip(
          label: customLabel ?? 'Urgent',
          textColor: AppColors.chipUrgentText,
          backgroundColor: AppColors.chipUrgentBg,
          icon: Icons.error_outline,
        );
      case DeadlineCategory.dueSoon:
        return StatusChip(
          label: customLabel ?? 'Due Soon',
          textColor: AppColors.chipDueSoonText,
          backgroundColor: AppColors.chipDueSoonBg,
          icon: Icons.alarm,
        );
      case DeadlineCategory.later:
        return StatusChip(
          label: customLabel ?? 'Later',
          textColor: AppColors.chipLaterText,
          backgroundColor: AppColors.chipLaterBg,
          icon: Icons.calendar_today_outlined,
        );
      case DeadlineCategory.overdue:
        return StatusChip(
          label: customLabel ?? 'Overdue',
          textColor: AppColors.chipOverdueText,
          backgroundColor: AppColors.chipOverdueBg,
          icon: Icons.warning_amber_rounded,
        );
      case DeadlineCategory.submitted:
        return StatusChip(
          label: customLabel ?? 'Submitted',
          textColor: AppColors.chipSubmittedText,
          backgroundColor: AppColors.chipSubmittedBg,
          icon: Icons.check_circle_outline,
        );
    }
  }

  /// Factory constructor to create a chip for application workflow status.
  factory StatusChip.fromStatus(String status) {
    final normalized = status.trim().toLowerCase();
    switch (normalized) {
      case 'submitted':
        return const StatusChip(
          label: 'Submitted',
          textColor: AppColors.chipSubmittedText,
          backgroundColor: AppColors.chipSubmittedBg,
          icon: Icons.check_circle_outline,
        );
      case 'ready to submit':
        return const StatusChip(
          label: 'Ready to Submit',
          textColor: AppColors.secondaryTeal,
          backgroundColor: Color(0xFFE0F2F1),
          icon: Icons.thumb_up_alt_outlined,
        );
      case 'in progress':
        return const StatusChip(
          label: 'In Progress',
          textColor: AppColors.primaryBlue,
          backgroundColor: AppColors.lightBlueSurface,
          icon: Icons.timelapse,
        );
      case 'not started':
      default:
        return const StatusChip(
          label: 'Not Started',
          textColor: AppColors.textSecondary,
          backgroundColor: Color(0xFFF0F2F5),
          icon: Icons.radio_button_unchecked,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
