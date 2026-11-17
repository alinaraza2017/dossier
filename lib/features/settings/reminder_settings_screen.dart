import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/shared_design_widgets.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  bool _deadlineReminders = true;
  bool _trialBillingAlerts = true;

  final Set<int> _selectedDays = {14, 7, 2, 1};
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

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
                  activeThumbColor: AppColors.secondaryTeal,
                  value: _deadlineReminders,
                  onChanged: (val) => setState(() => _deadlineReminders = val),
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
                  activeThumbColor: AppColors.secondaryTeal,
                  value: _trialBillingAlerts,
                  onChanged: (val) => setState(() => _trialBillingAlerts = val),
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
                      onTap: () {
                        setState(() {
                          if (isChecked) {
                            if (_selectedDays.length > 1) {
                              _selectedDays.remove(offset);
                            }
                          } else {
                            if (_selectedDays.length < 5) {
                              _selectedDays.add(offset);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('You can choose up to 5 reminder days.')),
                              );
                            }
                          }
                        });
                      },
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
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _reminderTime,
              );
              if (picked != null) {
                setState(() => _reminderTime = picked);
              }
            },
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
                  _reminderTime.format(context),
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
            'Choose up to 5 reminders. New applications use these days; you can still change them for each application.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
