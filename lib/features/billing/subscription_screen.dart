import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/shared_design_widgets.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          // Status Card (Fig 13.13)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.workspace_premium_rounded, color: AppColors.proGold, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Pro free trial',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                          color: AppColors.chipSubmittedText,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '5 days left · ends 12 Oct 2026, 10:00 AM',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.3,
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.proGold),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Your trial timeline',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          // Timeline Card (Fig 13.13)
          AppCard(
            child: Column(
              children: [
                _buildTimelineItem(
                  isDone: true,
                  title: 'Trial started',
                  subtitle: 'Mon 5 Oct, 10:00 AM',
                  dotColor: AppColors.successGreen,
                ),
                _buildTimelineItem(
                  isDone: false,
                  title: 'Reminder: 2 days left',
                  subtitle: 'Sat 10 Oct, 10:00 AM',
                  dotColor: AppColors.warningAmber,
                ),
                _buildTimelineItem(
                  isDone: false,
                  title: 'Reminder: ends tomorrow',
                  subtitle: 'Sun 11 Oct, 10:00 AM',
                  dotColor: AppColors.warningAmber,
                ),
                _buildTimelineItem(
                  isDone: false,
                  title: 'Trial ends, choose a plan or stay Free',
                  subtitle: 'Mon 12 Oct, 10:00 AM',
                  dotColor: AppColors.primaryBlue,
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Information Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightBlueSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'No payment is taken during the trial. If you do not choose a plan, Dossier moves to Free and keeps all your data.',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textMain),
            ),
          ),

          const SizedBox(height: 24),

          PrimaryButton(
            label: 'Choose a plan',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Google Play plans...')),
              );
            },
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Restore purchases',
                  style: TextStyle(fontFamily: 'Poppins', color: AppColors.primaryBlue, fontSize: 13),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Manage in Google Play',
                  style: TextStyle(fontFamily: 'Poppins', color: AppColors.primaryBlue, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
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
