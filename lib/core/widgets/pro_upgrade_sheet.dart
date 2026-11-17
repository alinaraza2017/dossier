import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ProUpgradeSheet extends StatelessWidget {
  const ProUpgradeSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ProUpgradeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header badge & title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8A33D), Color(0xFFE65100)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Unlock Dossier Pro',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Text(
            'Get unrestricted access to empower all your global scholarship applications.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),

          // Pro Features comparison list
          _buildFeatureItem(
            icon: Icons.all_inclusive_rounded,
            title: 'Unlimited Applications',
            subtitle: 'Free allows up to 5 active applications. Pro has no limits.',
          ),
          _buildFeatureItem(
            icon: Icons.auto_awesome_rounded,
            title: 'Unlimited AI Assistant',
            subtitle: 'Generate endless checklists, priority analysis & instant summaries.',
          ),
          _buildFeatureItem(
            icon: Icons.edit_notifications_rounded,
            title: 'Custom Reminder Alerts',
            subtitle: 'Set custom reminder intervals (1, 3, 7, 14 days before deadline).',
          ),
          _buildFeatureItem(
            icon: Icons.cloud_sync_rounded,
            title: 'Cloud Backup & Multi-Device Sync',
            subtitle: 'Never lose your deadlines when switching phones or laptops.',
          ),
          _buildFeatureItem(
            icon: Icons.attach_file_rounded,
            title: 'Document Attachments & Storage',
            subtitle: 'Attach transcripts, IELTS & motivation letters directly to scholarships.',
          ),
          _buildFeatureItem(
            icon: Icons.picture_as_pdf_rounded,
            title: 'PDF & Calendar Export',
            subtitle: 'Export scholarship timelines directly to Google Calendar or PDF reports.',
          ),

          const SizedBox(height: 18),

          // Pricing badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.lightBlueSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Student Special Plan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    Text(
                      'Billed annually • Cancel anytime',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$1.99 / mo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    Text(
                      'Save 50%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryTeal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action button
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎉 Dossier Pro simulated: All features unlocked for your session!'),
                  backgroundColor: AppColors.primaryBlue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Upgrade to Pro',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Continue with Free Plan',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.lightBlueSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
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
