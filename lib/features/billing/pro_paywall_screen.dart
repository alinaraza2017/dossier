import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/shared_design_widgets.dart';

class ProPaywallScreen extends StatefulWidget {
  const ProPaywallScreen({super.key});

  @override
  State<ProPaywallScreen> createState() => _ProPaywallScreenState();
}

class _ProPaywallScreenState extends State<ProPaywallScreen> {
  bool _isYearly = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No purchases to restore. Billing is part of Phase 2.')),
              );
            },
            child: const Text('Restore', style: TextStyle(color: AppColors.primaryBlue)),
          ),
        ],
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // Header (Fig 13.12)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.proGoldLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: AppColors.proGold, size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dossier Pro',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Everything you need to apply widely',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Features List
          _buildFeature('Unlimited applications', 'Free keeps 5 active at a time'),
          _buildFeature('Custom reminders', 'Any days before, any time of day'),
          _buildFeature('More AI help', '300 AI uses a month instead of 5'),
          _buildFeature('Cloud backup and sync', 'Keep your data on every phone'),
          _buildFeature('Document vault', 'Store passport, IELTS and transcripts'),
          _buildFeature('Export, calendar and dark mode', 'PDF report, calendar adding, dark theme'),

          const SizedBox(height: 20),

          // Yearly Plan Card (Pre-selected)
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
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Row(
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
                            Text(
                              'Yearly',
                              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              'Rs 333 a month',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rs 3,999',
                            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'per year',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    top: -30,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryTeal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Save 33%',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryTeal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Monthly Plan Card
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
                        Text(
                          'Monthly',
                          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          'Billed every month',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Rs 499\n/ month',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Main Action Button (Fig 13.12)
          PrimaryButton(
            label: 'Start 7-day free trial',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preview: Dossier Pro (trial and Google Play Billing) is Phase 2 and is not active in this build.')),
              );
            },
          ),

          const SizedBox(height: 10),
          const Text(
            'Free for 7 days, no card needed now. We remind you 2 days and 1 day before it ends. Pay only if you choose a plan. Cancel anytime in Google Play.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.lightBlueSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Phase 2 preview: prices come from Google Play and the trial is started by the server, so purchasing is not active in this build.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textMain),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFeature(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.secondaryTeal, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
