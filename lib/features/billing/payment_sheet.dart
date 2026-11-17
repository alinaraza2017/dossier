import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/shared_design_widgets.dart';

class PaymentSheet extends StatelessWidget {
  final String planTitle;
  final String price;
  final String renewsText;

  const PaymentSheet({
    super.key,
    this.planTitle = 'Dossier Pro, Yearly',
    this.price = 'Rs 3,999',
    this.renewsText = 'Renews every year on 12 Oct until you cancel',
  });

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const PaymentSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header with Google Play badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Google Play · secure payment',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary),
              ),
              Icon(Icons.shield_outlined, size: 16, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 14),

          // Product Summary Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightBlueSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.description, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planTitle,
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Dossier: Scholarship Planner',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Text(
            renewsText,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Payment simulation notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: const [
                Icon(Icons.credit_card, color: AppColors.primaryBlue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Card details are entered directly in Google Play\'s sheet (never inside Dossier).',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          PrimaryButton(
            label: 'Subscribe',
            onPressed: () {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              messenger.showSnackBar(
                const SnackBar(content: Text('Preview: Dossier Pro (trial and Google Play Billing) is Phase 2 and is not active in this build.')),
              );
            },
          ),

          const SizedBox(height: 8),
          const Text(
            'Card details are entered in Google Play, never inside Dossier. Cancel anytime in Play Store › Payments & subscriptions.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
