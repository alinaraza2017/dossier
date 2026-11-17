import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/shared_design_widgets.dart';
import 'package:provider/provider.dart';
import '../../providers/scholarship_provider.dart';
import '../../services/local_settings_service.dart';
import '../billing/pro_paywall_screen.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  // Saved in shared_preferences so the choice survives restarts (§17).
  bool _deadlineReminders = LocalSettingsService.instance.areRemindersEnabled();
  bool _trialBillingAlerts =
      LocalSettingsService.instance.areBillingAlertsEnabled();

  // Free plan: fixed 7 and 2 days before at 9:00 AM. Custom days/time are Pro.
  final Set<int> _selectedDays = {7, 2};

  void _openPro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProPaywallScreen()),
    );
  }

  Future<void> _setDeadlineReminders(bool value) async {
    setState(() => _deadlineReminders = value);
    await LocalSettingsService.instance.setRemindersEnabled(value);
    if (!mounted) return;
    // Turning reminders off cancels them all; on reschedules them (§17).
    await context.read<ScholarshipProvider>().resyncAllReminders(enabled: value);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value
            ? 'Reminders scheduled for all active applications.'
            : 'All deadline reminders cancelled.'),
      ),
    );
  }

  final List<int> _availableOffsets = [30, 14, 7, 3, 2, 1, 0];

  String _offsetLabel(int offset) {
    if (offset == 0) return 'On the deadline day';
    return '$offset ${offset == 1 ? "day" : "days"} before';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Reminders',
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
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Deadline reminders',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'For all applications',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
                  ),
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.secondaryTeal,
                  value: _deadlineReminders,
                  onChanged: _setDeadlineReminders,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Trial and billing alerts',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'Trial ending, payment problems',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
                  ),
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.secondaryTeal,
                  value: _trialBillingAlerts,
                  onChanged: (val) {
                    setState(() => _trialBillingAlerts = val);
                    LocalSettingsService.instance.setBillingAlertsEnabled(val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Default reminder days (Fig 13.20)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Default reminder days',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ProChip(),
            ],
          ),
          const SizedBox(height: 10),

          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: _availableOffsets.map((offset) {
                final isChecked = _selectedDays.contains(offset);
                return Column(
                  children: [
                    ListTile(
                      dense: true,
                      title: Text(
                        _offsetLabel(offset),
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                      ),
                      trailing: Icon(
                        isChecked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        color: isChecked ? AppColors.secondaryTeal : AppColors.border,
                      ),
                      onTap: _openPro,
                    ),
                    if (offset != _availableOffsets.last) const Divider(height: 1, indent: 16),
                  ],
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          // Reminder Time Card
          AppCard(
            onTap: _openPro,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminder time',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Used for every reminder',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Text(
                  '09:00',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          const Text(
            'Free plan: every application is reminded 7 and 2 days before at 9:00 AM. With Pro you can choose up to 5 days and any time.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
