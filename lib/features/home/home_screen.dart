import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/shared_design_widgets.dart';
import '../../providers/scholarship_provider.dart';
import '../billing/pro_paywall_screen.dart';
import 'package:intl/intl.dart';
import '../billing/upgrade_sheet.dart';
import '../navigation/main_navigation.dart';
import 'widgets/scholarship_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScholarshipProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12, right: 4),
        child: SizedBox(
          width: 56,
          height: 56,
          child: FloatingActionButton(
            onPressed: () => openAddApplication(context),
            backgroundColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 3,
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.loadScholarships(),
          color: AppColors.primaryBlue,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // Header: greeting + today's date (Fig 13.3)
              Text(
                _greeting(),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('EEEE, d MMM yyyy').format(DateTime.now()),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 16),

              // Plan card: everyone starts on Free (§1.3). Tapping shows Pro.
              _PlanBanner(activeCount: provider.activeScholarships.length),

              const SizedBox(height: 16),

              // 3 Summary Cards (Fig 13.3)
              Row(
                children: [
                  _buildSummaryCard(
                    context,
                    count: '${provider.activeScholarships.length}',
                    label: 'Active',
                    countColor: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 10),
                  _buildSummaryCard(
                    context,
                    count: '${provider.urgentApplicationsCount}',
                    label: 'Urgent',
                    countColor: AppColors.errorRed,
                  ),
                  const SizedBox(width: 10),
                  _buildSummaryCard(
                    context,
                    count: '${provider.submittedScholarships.length}',
                    label: 'Submitted',
                    countColor: AppColors.successGreen,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Upcoming Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upcoming',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  TextButton(
                    onPressed: () => MainNavigation.switchTab(context, 1),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Empty or List
              if (provider.activeScholarships.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.school_outlined, size: 48, color: AppColors.primaryBlue),
                      const SizedBox(height: 12),
                      const Text(
                        'No scholarship applications yet',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Add your first scholarship or load realistic sample data.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => provider.loadSampleData(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Load Demo Scholarships'),
                      ),
                    ],
                  ),
                )
              else
                ...provider.activeScholarships.map((app) {
                  final progress = provider.getProgressFor(app.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ScholarshipCard(
                      scholarship: app,
                      completedCount: progress.completed,
                      totalCount: progress.total,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.applicationDetails,
                          arguments: app.id,
                        );
                      },
                    ),
                  );
                }),

              // Submitted applications stay reachable (read, edit, reopen)
              if (provider.submittedScholarships.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Submitted (${provider.submittedScholarships.length})',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 10),
                ...provider.submittedScholarships.map((app) {
                  final progress = provider.getProgressFor(app.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ScholarshipCard(
                      scholarship: app,
                      completedCount: progress.completed,
                      totalCount: progress.total,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.applicationDetails,
                          arguments: app.id,
                        );
                      },
                    ),
                  );
                }),
              ],

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String count,
    required String label,
    required Color countColor,
  }) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: countColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens Add Application, or the Upgrade sheet when the Free limit of
/// 5 active applications is reached (§7.1, Flow 10). Submitted do not count.
void openAddApplication(BuildContext context) {
  final provider = context.read<ScholarshipProvider>();
  final active = provider.activeScholarships.length;
  if (active >= ScholarshipProvider.freeActiveLimit) {
    UpgradeSheet.show(context, activeCount: active);
    return;
  }
  Navigator.of(context).pushNamed(AppRoutes.addApplication);
}

class _PlanBanner extends StatelessWidget {
  final int activeCount;
  const _PlanBanner({required this.activeCount});

  @override
  Widget build(BuildContext context) {
    final limit = ScholarshipProvider.freeActiveLimit;
    final atLimit = activeCount >= limit;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProPaywallScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_user_outlined,
                color: AppColors.primaryBlue, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Free plan · $activeCount of $limit active',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    atLimit
                        ? 'Limit reached · submitted ones do not count'
                        : 'Works offline, no account needed.',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const ProChip(),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
