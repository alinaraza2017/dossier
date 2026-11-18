import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/shared_design_widgets.dart';
import '../../providers/ai_provider.dart';
import '../../providers/scholarship_provider.dart';
import '../../services/export_service.dart';
import '../../services/local_settings_service.dart';
import '../auth/sign_in_screen.dart';
import '../billing/pro_paywall_screen.dart';
import '../billing/subscription_screen.dart';
import 'reminder_settings_screen.dart';

/// Settings (§17, Fig 13.10). Shows the real current state: Free plan,
/// no account, data on this phone. Pro options carry a PRO label and open
/// the Dossier Pro screen instead of failing silently (§15.3).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScholarshipProvider>();
    final aiConfigured = context.watch<AiProvider>().isAiConfigured;
    final activeCount = provider.activeScholarships.length;
    final remindersOn = LocalSettingsService.instance.areRemindersEnabled();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 16),

            // Profile: Free works without an account (§7.6)
            AppCard(
              onTap: () => _push(context, const SignInScreen()),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.lightBlueSurface,
                    child: Icon(Icons.person_outline_rounded,
                        color: AppColors.primaryBlue),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Using Dossier without an account',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Your data is saved on this phone',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Plan card (Fig 13.10)
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(16),
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
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$activeCount of 5 active',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (activeCount / 5).clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.proGold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Submitted applications do not count.',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white70,
                              fontSize: 11),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _push(context, const ProPaywallScreen()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'See Pro',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _sectionTitle('PREFERENCES'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _tile(
                    icon: Icons.notifications_outlined,
                    title: 'Reminders',
                    subtitle: remindersOn
                        ? 'On · 7 and 2 days before · 9:00 AM'
                        : 'Off',
                    onTap: () =>
                        _push(context, const ReminderSettingsScreen()),
                  ),
                  _divider(),
                  _tile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Appearance',
                    subtitle: 'Light · Dark mode is a Pro feature',
                    trailing: const ProChip(),
                    onTap: () => _push(context, const ProPaywallScreen()),
                  ),
                  _divider(),
                  _tile(
                    icon: Icons.auto_awesome_outlined,
                    title: 'AI assistant',
                    subtitle: aiConfigured
                        ? 'Gemini AI · 3 focused features'
                        : 'Offline mode · rule-based extraction',
                    onTap: () => _showAiInfo(context, aiConfigured),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _sectionTitle('DATA'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _tile(
                    icon: Icons.download_outlined,
                    title: 'Export data (CSV)',
                    subtitle: 'All applications and requirements · Free',
                    onTap: () => _export(context, provider),
                  ),
                  _divider(),
                  _tile(
                    icon: Icons.cloud_sync_outlined,
                    title: 'Backup & sync',
                    subtitle: 'Keep data safe across phones',
                    trailing: const ProChip(),
                    onTap: () => _push(context, const ProPaywallScreen()),
                  ),
                  _divider(),
                  _tile(
                    icon: Icons.folder_open_outlined,
                    title: 'Document vault',
                    subtitle: 'Passport, IELTS, transcripts',
                    trailing: const ProChip(),
                    onTap: () => _push(context, const ProPaywallScreen()),
                  ),
                  _divider(),
                  _tile(
                    icon: Icons.delete_sweep_outlined,
                    title: 'Clear data on this phone',
                    subtitle: 'Deletes all applications',
                    iconColor: AppColors.errorRed,
                    onTap: () => _confirmClear(context, provider),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _sectionTitle('ACCOUNT'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _tile(
                    icon: Icons.credit_card_outlined,
                    title: 'Subscription & billing',
                    subtitle: 'Free plan · Pro previews',
                    onTap: () => _push(context, const SubscriptionScreen()),
                  ),
                  _divider(),
                  _tile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help, privacy and terms',
                    onTap: () => _showAbout(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context, ScholarshipProvider provider) async {
    final messenger = ScaffoldMessenger.of(context);
    if (provider.scholarships.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Nothing to export yet.')),
      );
      return;
    }
    try {
      await ExportService.exportAndShare(provider.scholarships);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _confirmClear(
      BuildContext context, ScholarshipProvider provider) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Clear all data?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This deletes every application, requirement and reminder on this phone. Type DELETE to confirm.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(hintText: 'DELETE'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: controller.text.trim() == 'DELETE'
                  ? () => Navigator.pop(ctx, true)
                  : null,
              child: const Text('Delete everything',
                  style: TextStyle(color: AppColors.errorRed)),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      await provider.clearAllData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data on this phone was cleared.')),
        );
      }
    }
  }

  void _showAiInfo(BuildContext context, bool aiConfigured) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('AI assistant'),
        content: Text(
          aiConfigured
              ? 'Dossier uses Gemini for three focused features: checklist, priority and summary. You always review results before they are saved.'
              : 'This build runs the AI features in offline mode: a rule-based engine extracts checklist items and ranks applications by deadline and progress. With an API key (or the Phase 2 server proxy) the same screens use Gemini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Dossier',
      applicationVersion: 'Version 1.0 (Phase 1)',
      applicationLegalese: 'Scholarship Application Planner\nFA23-BSE-015',
      children: const [
        SizedBox(height: 12),
        Text(
          'Privacy: all data stays on this phone in a local SQLite database. '
          'No account, no ads, no tracking. AI features send only requirement '
          'text, days left and progress, never notes, links or documents.',
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 56);

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primaryBlue).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primaryBlue, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: iconColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: trailing ??
          const Icon(Icons.chevron_right,
              color: AppColors.textSecondary, size: 20),
      onTap: onTap,
    );
  }
}
