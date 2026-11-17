import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/shared_design_widgets.dart';
import '../../providers/scholarship_provider.dart';
import '../billing/pro_paywall_screen.dart';
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
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.addApplication);
            },
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
              // Header: Good morning, Alina (Fig 13.3)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Good morning, Alina',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Wednesday, 7 Oct 2026',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.lightBlueSurface,
                    child: const Text(
                      'A',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Pro Trial Banner (Fig 13.3)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProPaywallScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.proGoldLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.proGold.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.workspace_premium_rounded,
                        color: AppColors.proGoldText,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Pro trial · 5 days left',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.proGoldText,
                              ),
                            ),
                            SizedBox(height: 1),
                            Text(
                              'Ends 12 Oct, 10:00 AM. No card needed until then.',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: AppColors.proGoldText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.proGoldText,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

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
                    onPressed: () {
                      // Switch to tab 1 (Deadlines)
                    },
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

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
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
