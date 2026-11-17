import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/shared_design_widgets.dart';

class DocumentVaultScreen extends StatefulWidget {
  const DocumentVaultScreen({super.key});

  @override
  State<DocumentVaultScreen> createState() => _DocumentVaultScreenState();
}

class _DocumentVaultScreenState extends State<DocumentVaultScreen> {
  final List<Map<String, dynamic>> _mockDocs = [
    {
      'title': 'Passport',
      'type': 'PDF',
      'size': '1.4 MB',
      'usedIn': 'Used in 3 applications',
      'expiry': 'Expires Mar 2027',
      'isExpiringSoon': false,
    },
    {
      'title': 'IELTS Certificate',
      'type': 'PDF',
      'size': '0.9 MB',
      'usedIn': 'Used in 3 applications',
      'expiry': 'Expires 29 Dec',
      'isExpiringSoon': true,
    },
    {
      'title': 'Academic Transcript',
      'type': 'PDF',
      'size': '2.6 MB',
      'usedIn': 'Used in 2 applications',
      'expiry': null,
      'isExpiringSoon': false,
    },
    {
      'title': 'CNIC copy',
      'type': 'JPG',
      'size': '1.3 MB',
      'usedIn': 'Not linked yet',
      'expiry': null,
      'isExpiringSoon': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Document Vault',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: ProChip(),
          ),
        ],
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Storage Card (Fig 13.17)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Storage',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '6.2 MB of 1 GB',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.0062,
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryTeal),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'PDF, JPG or PNG · up to 10 MB each',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My documents',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                '${_mockDocs.length}',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Document List Rows
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: _mockDocs.map((doc) {
                final isLast = doc == _mockDocs.last;
                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlueSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.description_outlined, color: AppColors.primaryBlue, size: 20),
                      ),
                      title: Text(
                        doc['title'] as String,
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${doc['type']} · ${doc['size']} · ${doc['usedIn']}',
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
                      ),
                      trailing: doc['expiry'] != null
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (doc['isExpiringSoon'] as bool)
                                    ? AppColors.chipDueSoonBg
                                    : AppColors.chipLaterBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                doc['expiry'] as String,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: (doc['isExpiringSoon'] as bool)
                                      ? AppColors.chipDueSoonText
                                      : AppColors.chipLaterText,
                                ),
                              ),
                            )
                          : null,
                    ),
                    if (!isLast) const Divider(height: 1, indent: 56),
                  ],
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          // Expiry Warning Banner (Fig 13.17)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.chipDueSoonBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.warningAmber.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.notifications_active_outlined, color: AppColors.chipDueSoonText, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your IELTS certificate expires on 29 Dec 2026. Check that it is still valid for DAAD.',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.chipDueSoonText),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          PrimaryButton(
            icon: Icons.add,
            label: 'Upload document',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preview: the document vault (Firebase Storage) is part of Phase 2.')),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
