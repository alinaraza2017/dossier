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
    final submittedApps = scholarshipProvider.submittedScholarships;
    final urgentList = <Scholarship>[];
    final dueSoonList = <Scholarship>[];
    final laterList = <Scholarship>[];
    final overdueList = <Scholarship>[];

    // Labels follow §7.3: Urgent 0-7, Due soon 8-21, Later 22+, Overdue < 0.
    for (final app in activeApps) {
      final days = AppDateUtils.daysRemaining(app.deadlineDateTime);
      if (days < 0) {
        overdueList.add(app);
      } else if (days <= 7) {
        urgentList.add(app);
      } else if (days <= 21) {
        dueSoonList.add(app);
      } else {
        laterList.add(app);
      }
    }

    final filter = deadlineProvider.selectedFilter;
    bool show(DeadlineFilter f) => filter == DeadlineFilter.all || filter == f;

    final sections = <Widget>[];
    void addSection(
      DeadlineFilter f,
      String title,
      Color color,
      List<Scholarship> items,
      String emptyText,
    ) {
      if (!show(f)) return;
      // In "All", hide empty optional groups to keep the screen short.
      if (filter == DeadlineFilter.all &&
          items.isEmpty &&
          f != DeadlineFilter.urgent &&
          f != DeadlineFilter.overdue) {
        return;
      }
      sections
        ..add(_buildSectionHeader(title, color))
        ..add(const SizedBox(height: 8));
      if (items.isEmpty) {
        sections.add(f == DeadlineFilter.overdue
            ? AppCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: AppColors.successGreen, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'No overdue applications',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppColors.textMain),
                    ),
                  ],
                ),
              )
            : _buildEmptySection(emptyText));
      } else {
        sections.addAll(items.map((app) =>
            _buildDeadlineCard(context, scholarshipProvider, app, color)));
      }
      sections.add(const SizedBox(height: 20));
    }

    addSection(DeadlineFilter.urgent, 'Urgent · 0 to 7 days',
        AppColors.errorRed, urgentList, 'No urgent applications');
    addSection(DeadlineFilter.dueSoon, 'Due soon · 8 to 21 days',
        AppColors.warningAmber, dueSoonList, 'Nothing due in 8 to 21 days');
    addSection(DeadlineFilter.later, 'Later · 22+ days', AppColors.primaryBlue,
        laterList, 'Nothing due later');
    addSection(DeadlineFilter.overdue, 'Overdue', AppColors.chipUrgentText,
        overdueList, 'No overdue applications');
    if (filter == DeadlineFilter.submitted) {
      addSection(DeadlineFilter.submitted, 'Submitted', AppColors.successGreen,
          submittedApps, 'No submitted applications yet');
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
              '${activeApps.length} active · ${submittedApps.length} submitted · sorted by date',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            // Filter Chips (Fig 13.7)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final (label, f) in [
                    ('All', DeadlineFilter.all),
                    ('Urgent', DeadlineFilter.urgent),
                    ('Due soon', DeadlineFilter.dueSoon),
                    ('Later', DeadlineFilter.later),
                    ('Overdue', DeadlineFilter.overdue),
                    ('Submitted', DeadlineFilter.submitted),
                  ]) ...[
                    _buildFilterChip(
                      label: label,
                      isSelected: filter == f,
                      onTap: () => deadlineProvider.setFilter(f),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (activeApps.isEmpty && submittedApps.isEmpty)
              _buildEmptySection(
                  'No applications yet. Add your first scholarship from Home.')
            else
              ...sections,

            const SizedBox(height: 10),
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
                    'Due ${AppDateUtils.formatDisplay(app.deadlineDateTime)} · ${progress.total == 0 ? 'No requirements yet' : remainingReqs == 0 ? 'All requirements done' : remainingReqs == 1 ? '1 requirement left' : '$remainingReqs requirements left'}',
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
                  app.isSubmitted
                      ? 'Done'
                      : days < 0
                          ? '${-days}'
                          : '$days',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: indicatorColor,
                  ),
                ),
                if (!app.isSubmitted)
                  Text(
                    days < 0
                        ? (days == -1 ? 'day overdue' : 'days overdue')
                        : days == 0
                            ? 'due today'
                            : days == 1
                                ? 'day left'
                                : 'days left',
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
