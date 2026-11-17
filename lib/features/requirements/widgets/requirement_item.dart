import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/requirement.dart';

class RequirementItem extends StatelessWidget {
  final Requirement requirement;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RequirementItem({
    super.key,
    required this.requirement,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = requirement.isDone;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isDone,
            onChanged: onToggle,
            activeColor: AppColors.secondaryTeal,
          ),
          Expanded(
            child: Text(
              requirement.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDone ? AppColors.textSecondary : AppColors.textMain,
                decoration: isDone ? TextDecoration.lineThrough : null,
                fontWeight: isDone ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Rename',
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 18,
              color: AppColors.errorRed,
            ),
            tooltip: 'Delete',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
