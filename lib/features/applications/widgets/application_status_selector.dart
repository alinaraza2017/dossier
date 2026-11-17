import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class ApplicationStatusSelector extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onStatusChanged;

  const ApplicationStatusSelector({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  static const List<String> statuses = [
    AppStrings.statusNotStarted,
    AppStrings.statusInProgress,
    AppStrings.statusReadyToSubmit,
    AppStrings.statusSubmitted,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Application Status',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: statuses.map((status) {
            final isSelected =
                selectedStatus.toLowerCase() == status.toLowerCase();
            return ChoiceChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (_) => onStatusChanged(status),
              selectedColor: AppColors.primaryBlue,
              backgroundColor: AppColors.cardSurface,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textMain,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primaryBlue : AppColors.border,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }
}
