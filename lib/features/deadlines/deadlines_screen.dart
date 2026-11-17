import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/shared_design_widgets.dart';
import '../../data/models/scholarship.dart';
import '../../providers/deadline_provider.dart';
import '../../providers/scholarship_provider.dart';

class DeadlinesScreen extends StatelessWidget {
  const DeadlinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deadlineProvider = context.watch<DeadlineProvider>();
    final scholarshipProvider = context.watch<ScholarshipProvider>();

    final activeApps = scholarshipProvider.activeScholarships;
    final urgentList = <Scholarship>[];
    final upcomingList = <Scholarship>[];
    final overdueList = <Scholarship>[];

    for (final app in activeApps) {
      final days = AppDateUtils.daysRemaining(app.deadlineDateTime);
      if (days < 0) {
        overdueList.add(app);
      } else if (days <= 7) {
        urgentList.add(app);
      } else {
        upcomingList.add(app);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Title (Fig 13.7)
            const Text(
              'Deadlines',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${activeApps.length} active · sorted by date',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            // Filter Chips (Fig 13.7)
            Row(
              children: [
                _buildFilterChip(
                  label: 'All',
                  isSelected: deadlineProvider.selectedFilter == DeadlineFilter.all,
                  onTap: () => deadlineProvider.setFilter(DeadlineFilter.all),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Urgent',
                  isSelected: deadlineProvider.selectedFilter == DeadlineFilter.urgent,
                  onTap: () => deadlineProvider.setFilter(DeadlineFilter.urgent),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Upcoming',
                  isSelected: deadlineProvider.selectedFilter == DeadlineFilter.dueSoon,
                  onTap: () => deadlineProvider.setFilter(DeadlineFilter.dueSoon),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Overdue',
                  isSelected: deadlineProvider.selectedFilter == DeadlineFilter.overdue,
                  onTap: () => deadlineProvider.setFilter(DeadlineFilter.overdue),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // URGENT SECTION
            _buildSectionHeader('Urgent · within 7 days', AppColors.errorRed),
            const SizedBox(height: 8),
            if (urgentList.isEmpty)
              _buildEmptySection('No urgent applications')
            else
              ...urgentList.map((app) => _buildDeadlineCard(context, scholarshipProvider, app, AppColors.errorRed)),

            const SizedBox(height: 20),

            // UPCOMING SECTION
            _buildSectionHeader('Upcoming', AppColors.warningAmber),
            const SizedBox(height: 8),
            if (upcomingList.isEmpty)
              _buildEmptySection('No upcoming applications')
            else
              ...upcomingList.map((app) => _buildDeadlineCard(context, scholarshipProvider, app, AppColors.warningAmber)),

            const SizedBox(height: 20),

            // OVERDUE SECTION
            _buildSectionHeader('Overdue', AppColors.errorRed),
            const SizedBox(height: 8),
            if (overdueList.isEmpty)
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle_outline_rounded, color: AppColors.successGreen, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'No overdue applications',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textMain),
                    ),
                  ],
                ),
              )
            else
              ...overdueList.map((app) => _buildDeadlineCard(context, scholarshipProvider, app, AppColors.errorRed)),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : AppColors.textMain,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySection(String message) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildDeadlineCard(
    BuildContext context,
    ScholarshipProvider provider,
    Scholarship app,
    Color indicatorColor,
  ) {
    final days = AppDateUtils.daysRemaining(app.deadlineDateTime);
    final progress = provider.getProgressFor(app.id);
    final remainingReqs = progress.total - progress.completed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.applicationDetails,
            arguments: app.id,
          );
        },
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.name,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Due ${AppDateUtils.formatDisplay(app.deadlineDateTime)} · $remainingReqs requirements left',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  days < 0 ? 'Overdue' : '$days',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: indicatorColor,
                  ),
                ),
                if (days >= 0)
                  const Text(
                    'days left',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
