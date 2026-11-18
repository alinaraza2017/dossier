import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/shared_design_widgets.dart';
import 'package:provider/provider.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/scholarship_provider.dart';
import '../applications/choose_5_screen.dart';
import '../auth/sign_in_screen.dart';
import '../trial/trial_ended_screen.dart';
import '../vault/document_vault_screen.dart';
import 'payment_sheet.dart';
import 'pro_paywall_screen.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeCount = context.watch<ScholarshipProvider>().activeScholarships.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Subscription & Billing',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Status Card (Fig 13.13): the real current plan
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Free plan',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.chipSubmittedBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.chipSubmittedText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$activeCount of 5 active applications · no account needed · works offline',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'How the 7-day Pro trial works',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          AppCard(
            child: Column(
              children: [
                _buildTimelineItem(
                  isDone: false,
                  title: 'Day 1: trial starts on the server',
                  subtitle: 'Needs a verified account. No card is asked.',
                  dotColor: AppColors.successGreen,
                ),
                _buildTimelineItem(
                  isDone: false,
                  title: 'Day 6: "2 days left" reminder',
                  subtitle: 'Pick a plan to keep Pro, or continue with Free.',
                  dotColor: AppColors.warningAmber,
                ),
                _buildTimelineItem(
                  isDone: false,
                  title: 'Day 7: "Ends tomorrow" reminder',
                  subtitle: 'Exactly 168 hours after it started.',
                  dotColor: AppColors.warningAmber,
                ),
                _buildTimelineItem(
                  isDone: false,
                  title: 'Trial ends: choose a plan or stay Free',
                  subtitle: 'Nothing is charged automatically. No data is lost.',
                  dotColor: AppColors.primaryBlue,
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightBlueSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Dossier Pro is Phase 2 of this project. The trial and Google Play Billing are verified on the server (Cloud Functions), so they are not active in this build. The screens below are design previews.',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textMain),
            ),
          ),

          const SizedBox(height: 20),

          PrimaryButton(
            label: 'See Dossier Pro',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProPaywallScreen()),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Pro design previews',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _previewTile(context, Icons.login_rounded, 'Sign in / Create account',
                    () => _push(context, const SignInScreen())),
                const Divider(height: 1, indent: 16),
                _previewTile(context, Icons.payment_rounded, 'Google Play payment sheet',
                    () => PaymentSheet.show(context)),
                const Divider(height: 1, indent: 16),
                _previewTile(context, Icons.hourglass_bottom_rounded, 'Trial ended',
                    () => _push(context, const TrialEndedScreen())),
                const Divider(height: 1, indent: 16),
                _previewTile(context, Icons.checklist_rounded, 'Choose 5 to keep active', () {
                  final provider = context.read<ScholarshipProvider>();
                  final apps = provider.activeScholarships
                      .map((s) => {
                            'id': s.id,
                            'name': s.name,
                            'deadline': AppDateUtils.formatDisplay(s.deadlineDateTime),
                            'progress': provider.getProgressPercent(s.id),
                          })
                      .toList();
                  _push(context, Choose5Screen(applications: apps));
                }),
                const Divider(height: 1, indent: 16),
                _previewTile(context, Icons.folder_open_outlined, 'Document vault',
                    () => _push(context, const DocumentVaultScreen())),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _previewTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue, size: 20),
      title: Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
      trailing: const Text(
        'Preview',
        style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
      ),
      onTap: onTap,
    );
  }

  Widget _buildTimelineItem({
    required bool isDone,
    required String title,
    required String subtitle,
    required Color dotColor,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: isDone ? dotColor : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: 2),
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 8, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
