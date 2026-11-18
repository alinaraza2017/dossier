import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/shared_design_widgets.dart';

class TrialEndedScreen extends StatefulWidget {
  const TrialEndedScreen({super.key});

  @override
  State<TrialEndedScreen> createState() => _TrialEndedScreenState();
}

class _TrialEndedScreenState extends State<TrialEndedScreen> {
  bool _isYearly = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Icon Badge
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.chipDueSoonBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.access_time_rounded, color: AppColors.chipDueSoonText, size: 28),
              ),
            ),
            const SizedBox(height: 16),

            // Header (Fig 13.15)
            const Text(
              'Your Pro trial has ended',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Subscribe to keep Pro. Nothing is deleted if you stay on Free.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 20),

            // What you keep & Paused Card (Fig 13.15)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'On Free you keep',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildCheckItem('All applications, requirements and progress'),
                  _buildCheckItem('Reminders 7 and 2 days before, at 9:00 AM'),
                  _buildCheckItem('5 active applications (you choose which)'),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  const Text(
                    'Paused until you subscribe',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildLockItem('Custom reminders, backup and sync'),
                  _buildLockItem('Document vault uploads, export, dark mode'),
                  _buildLockItem('AI goes back to 5 uses a month'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Yearly Option Card
            GestureDetector(
              onTap: () => setState(() => _isYearly = true),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardSurface : AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isYearly ? AppColors.primaryBlue : AppColors.border,
                    width: _isYearly ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _isYearly ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: _isYearly ? AppColors.primaryBlue : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Yearly', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('Rs 333 a month', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Text('Rs 3,999\nper year', textAlign: TextAlign.end, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Monthly Option Card
            GestureDetector(
              onTap: () => setState(() => _isYearly = false),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardSurface : AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: !_isYearly ? AppColors.primaryBlue : AppColors.border,
                    width: !_isYearly ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      !_isYearly ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: !_isYearly ? AppColors.primaryBlue : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Monthly', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('Billed every month', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Text('Rs 499\nper month', textAlign: TextAlign.end, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            PrimaryButton(
              label: 'Subscribe, add payment',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preview: Dossier Pro (trial and Google Play Billing) is Phase 2 and is not active in this build.')),
                );
              },
            ),

            const SizedBox(height: 10),

            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Continue with Free',
                  style: TextStyle(fontFamily: 'Poppins', color: AppColors.primaryBlue, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check, size: 16, color: AppColors.successGreen),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildLockItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary))),
        ],
      ),
    );
  }
}
