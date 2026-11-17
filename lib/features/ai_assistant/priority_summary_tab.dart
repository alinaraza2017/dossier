import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/status_chip.dart';
import '../../providers/ai_provider.dart';
import '../../providers/scholarship_provider.dart';

class PrioritySummaryTab extends StatelessWidget {
  const PrioritySummaryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aiProvider = context.watch<AiProvider>();
    final sProvider = context.watch<ScholarshipProvider>();

    final activeApps = sProvider.activeScholarships;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Application Priority
          Container(
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlueSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.auto_graph_rounded,
                        color: AppColors.secondaryTeal,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Application Priority',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                          Text(
                            'Decide which application needs your attention first.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: 'Which Application Should I Work On First?',
                  icon: Icons.lightbulb_outline_rounded,
                  type: AppButtonType.primary,
                  isLoading: aiProvider.isLoadingPriority,
                  onPressed: activeApps.isEmpty
                      ? null
                      : () {
                          final progressMap =
                              <String, ({int completed, int total})>{};
                          for (final app in activeApps) {
                            progressMap[app.id] = sProvider.getProgressFor(
                              app.id,
                            );
                          }
                          aiProvider.generatePriority(
                            activeScholarships: activeApps,
                            progressMap: progressMap,
                          );
                        },
                ),
                if (activeApps.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'No active applications found. Add a scholarship to get recommendations.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Priority Results List
          if (aiProvider.isLoadingPriority)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: LoadingView(
                message: 'Analyzing deadlines and requirements...',
              ),
            )
          else if (aiProvider.priorityError != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.chipUrgentBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                aiProvider.priorityError!,
                style: const TextStyle(color: AppColors.errorRed),
              ),
            )
          else if (aiProvider.priorityResults.isNotEmpty) ...[
            Text(
              'Recommended Priority Order',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 10),
            ...aiProvider.priorityResults.map((item) {
              return InkWell(
                onTap: item.scholarshipId != null
                    ? () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.applicationDetails,
                          arguments: item.scholarshipId,
                        );
                      }
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
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
                          Row(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Center(
                                  child: Text(
                                    '#${item.rank}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                item.scholarshipName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                ),
                              ),
                            ],
                          ),
                          StatusChip(
                            label: item.daysRemaining < 0
                                ? '${item.daysRemaining.abs()}d overdue'
                                : '${item.daysRemaining}d left',
                            textColor: item.daysRemaining <= 7
                                ? AppColors.chipUrgentText
                                : AppColors.chipLaterText,
                            backgroundColor: item.daysRemaining <= 7
                                ? AppColors.chipUrgentBg
                                : AppColors.chipLaterBg,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.reason,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMain,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Progress: ${item.progressPercent}% complete',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          const SizedBox(height: 12),

          // Section 2: Progress Summary
          Container(
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlueSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.summarize_outlined,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progress Summary',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                          Text(
                            'A concise multi-application status overview.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: 'Summarize My Progress',
                  icon: Icons.notes_rounded,
                  type: AppButtonType.secondary,
                  isLoading: aiProvider.isLoadingSummary,
                  onPressed: activeApps.isEmpty
                      ? null
                      : () {
                          final progressMap =
                              <String, ({int completed, int total})>{};
                          for (final app in activeApps) {
                            progressMap[app.id] = sProvider.getProgressFor(
                              app.id,
                            );
                          }
                          aiProvider.generateProgressSummary(
                            activeScholarships: activeApps,
                            progressMap: progressMap,
                          );
                        },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Summary Output Card
          if (aiProvider.isLoadingSummary)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: LoadingView(message: 'Generating summary...'),
            )
          else if (aiProvider.summaryResult != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightBlueSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Your Progress Summary',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    aiProvider.summaryResult!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMain,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
