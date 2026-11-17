import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/scholarship.dart';
import '../../providers/scholarship_provider.dart';
import 'widgets/application_form.dart';

class AddApplicationScreen extends StatelessWidget {
  final Scholarship? scholarshipToEdit;

  const AddApplicationScreen({super.key, this.scholarshipToEdit});

  @override
  Widget build(BuildContext context) {
    final isEditing = scholarshipToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Application' : 'Add Application'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: ApplicationForm(
            initialScholarship: scholarshipToEdit,
            onSave: (scholarship) async {
              try {
                final provider = context.read<ScholarshipProvider>();
                if (isEditing) {
                  await provider.updateScholarship(scholarship);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Application updated successfully.'),
                        backgroundColor: AppColors.successGreen,
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                } else {
                  await provider.addScholarship(scholarship);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Scholarship application saved.'),
                        backgroundColor: AppColors.successGreen,
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to save application: $e'),
                      backgroundColor: AppColors.errorRed,
                    ),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
