import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_view.dart';
import '../../providers/ai_provider.dart';
import '../../providers/requirement_provider.dart';
import '../../providers/scholarship_provider.dart';

class ChecklistTab extends StatefulWidget {
  final String? initialTargetScholarshipId;

  const ChecklistTab({super.key, this.initialTargetScholarshipId});

  @override
  State<ChecklistTab> createState() => _ChecklistTabState();
}

class _ChecklistTabState extends State<ChecklistTab> {
  final TextEditingController _pasteController = TextEditingController();
  final TextEditingController _manualItemController = TextEditingController();
  String? _selectedScholarshipId;
  bool _isSavingToDb = false;

  @override
  void initState() {
    super.initState();
    _selectedScholarshipId = widget.initialTargetScholarshipId;
  }

  @override
  void dispose() {
    _pasteController.dispose();
    _manualItemController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerate() async {
    final text = _pasteController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please paste some requirement text first.'),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    await context.read<AiProvider>().generateChecklist(text);
  }

  Future<void> _handleSaveToScholarship() async {
    if (_isSavingToDb) return; // Prevent double taps

    final aiProvider = context.read<AiProvider>();
    final items = aiProvider.generatedChecklist;

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No checklist items to save.')),
      );
      return;
    }

    if (_selectedScholarshipId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a target scholarship.')),
      );
      return;
    }

    setState(() => _isSavingToDb = true);

    try {
      final reqProvider = context.read<RequirementProvider>();
      final sProvider = context.read<ScholarshipProvider>();

      final result =
          await reqProvider.addManyRequirements(_selectedScholarshipId!, items);
      await sProvider.refreshProgressFor(_selectedScholarshipId!);
      final name = sProvider.scholarships
          .firstWhere((s) => s.id == _selectedScholarshipId,
              orElse: () => sProvider.scholarships.first)
          .name;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Added ${result.added} to $name'
              '${result.skipped > 0 ? ' · ${result.skipped} already existed and were skipped' : ''}',
            ),
            backgroundColor: AppColors.successGreen,
          ),
        );
        aiProvider.clearChecklist();
        _pasteController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save requirements: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingToDb = false);
    }
  }

  void _showEditDialog(int index, String currentTitle) {
    final editController = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Item'),
        content: TextField(
          controller: editController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Requirement Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (editController.text.trim().isNotEmpty) {
                context.read<AiProvider>().editChecklistItem(
                  index,
                  editController.text.trim(),
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aiProvider = context.watch<AiProvider>();
    final sProvider = context.watch<ScholarshipProvider>();
    final scholarships = sProvider.activeScholarships;

    // Keep the selection valid (e.g. after a delete or a status change)
    if (_selectedScholarshipId != null &&
        !scholarships.any((s) => s.id == _selectedScholarshipId)) {
      _selectedScholarshipId = null;
    }
    // Automatically set default selected scholarship if none selected
    if (_selectedScholarshipId == null && scholarships.isNotEmpty) {
      _selectedScholarshipId = scholarships.first.id;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paste Scholarship Requirements',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            aiProvider.isAiConfigured
                ? 'Copy requirements from a scholarship website. Gemini AI turns them into a checklist you can review before saving.'
                : 'Copy requirements from a scholarship website. Dossier turns them into a checklist you can review before saving. (Offline mode: smart rule-based extraction.)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Text area
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: TextField(
              controller: _pasteController,
              maxLines: 5,
              maxLength: 4000,
              style: theme.textTheme.bodyMedium,
              decoration: const InputDecoration(
                hintText:
                    'e.g. Applicants must provide a valid passport, academic transcript, IELTS certificate, CV, motivation letter and two recommendation letters.',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 12),

          AppButton(
            text: 'Generate Checklist',
            icon: Icons.auto_awesome,
            type: AppButtonType.primary,
            isLoading: aiProvider.isLoadingChecklist,
            onPressed: _handleGenerate,
          ),
          const SizedBox(height: 24),

          // Generated Checklist Section
          if (aiProvider.isLoadingChecklist)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: LoadingView(message: 'Extracting requirement items...'),
            )
          else if (aiProvider.checklistError != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.chipUrgentBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.chipUrgentText.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.errorRed),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      aiProvider.checklistError!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.errorRed,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (aiProvider.generatedChecklist.isNotEmpty) ...[
            Text(
              'Review & Customize Items (${aiProvider.generatedChecklist.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Remove unneeded items or edit names before saving to your scholarship.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Item List
            ...aiProvider.generatedChecklist.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_box_outline_blank,
                      color: AppColors.secondaryTeal,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => _showEditDialog(index, item),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.errorRed,
                      ),
                      onPressed: () => aiProvider.removeChecklistItem(index),
                    ),
                  ],
                ),
              );
            }),

            // Manual Add Item Field
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _manualItemController,
                    decoration: const InputDecoration(
                      hintText: 'Add an extra item manually...',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryTeal,
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  onPressed: () {
                    final text = _manualItemController.text.trim();
                    if (text.isNotEmpty) {
                      aiProvider.addChecklistItem(text);
                      _manualItemController.clear();
                    }
                  },
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Target Scholarship Selector
            Text(
              'Target Scholarship',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 6),
            if (scholarships.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No scholarships available yet. Please add a scholarship first.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.errorRed,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedScholarshipId,
                    items: scholarships.map((s) {
                      return DropdownMenuItem<String>(
                        value: s.id,
                        child: Text(
                          s.country.isEmpty ? s.name : '${s.name} (${s.country})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (id) {
                      setState(() => _selectedScholarshipId = id);
                    },
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Confirm & Save Button
            AppButton(
              text: 'Save Checklist to Scholarship',
              icon: Icons.save_alt_rounded,
              type: AppButtonType.primary,
              isLoading: _isSavingToDb,
              onPressed: scholarships.isEmpty ? null : _handleSaveToScholarship,
            ),
          ] else
            EmptyState(
              icon: Icons.checklist_rtl_rounded,
              title: 'Ready to generate',
              description:
                  'Paste your requirements above and tap Generate Checklist to see the extracted items.',
            ),
        ],
      ),
    );
  }
}
