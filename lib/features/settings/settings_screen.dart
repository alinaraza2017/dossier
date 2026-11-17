import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/shared_design_widgets.dart';
import '../billing/pro_paywall_screen.dart';
import '../billing/subscription_screen.dart';
import '../vault/document_vault_screen.dart';
import 'reminder_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Profile Card
          AppCard(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account profile settings')),
              );
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.lightBlueSurface,
                  child: const Text(
                    'A',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alina Raza',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'alina.raza@gmail.com',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Plan Card (Fig 13.10)
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
                    const Row(
                      children: [
                        Icon(Icons.workspace_premium_rounded, color: AppColors.proGold, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Dossier Pro • Trial',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '5 days left',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.3,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.proGold),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ends 12 Oct 2026, 10:00 AM',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Choose a plan',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // PREFERENCES
          const Text(
            'PREFERENCES',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),

          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildListTile(
                  icon: Icons.notifications_outlined,
                  title: 'Reminders',
                  subtitle: '14, 7, 2, 1 days · 9:00 AM',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReminderSettingsScreen()),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildListTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Appearance',
                  subtitle: 'Dark mode',
                  trailing: const ProChip(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProPaywallScreen()),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildListTile(
                  icon: Icons.auto_awesome_outlined,
                  title: 'AI usage',
                  subtitle: '12 of 300 this month',
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // DATA
          const Text(
            'DATA',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),

          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildListTile(
                  icon: Icons.cloud_sync_outlined,
                  title: 'Backup & sync',
                  subtitle: 'Last synced 9:40 AM',
                  trailing: Switch(
                    value: true,
                    activeThumbColor: AppColors.secondaryTeal,
                    onChanged: (val) {},
                  ),
                ),
                const Divider(height: 1, indent: 56),
                _buildListTile(
                  icon: Icons.folder_open_outlined,
                  title: 'Document vault',
                  subtitle: '4 files · 6.2 MB of 1 GB',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DocumentVaultScreen()),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildListTile(
                  icon: Icons.download_outlined,
                  title: 'Export',
                  subtitle: 'PDF report, calendar, data file',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Exporting report & CSV...')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ACCOUNT
          const Text(
            'ACCOUNT',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),

          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildListTile(
                  icon: Icons.credit_card_outlined,
                  title: 'Subscription & billing',
                  subtitle: 'Managed by Google Play',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildListTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help, privacy and terms',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _buildListTile(
                  icon: Icons.logout_rounded,
                  title: 'Sign out',
                  iconColor: AppColors.errorRed,
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildListTile({
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
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
      onTap: onTap,
    );
  }
}
