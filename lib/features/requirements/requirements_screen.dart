import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/progress_indicator_card.dart';
import '../../data/models/scholarship.dart';
import '../../providers/requirement_provider.dart';
import '../../providers/scholarship_provider.dart';
import 'widgets/requirement_item.dart';

class RequirementsScreen extends StatefulWidget {
  final String scholarshipId;

  const RequirementsScreen({super.key, required this.scholarshipId});

  @override
  State<RequirementsScreen> createState() => _RequirementsScreenState();
}

class _RequirementsScreenState extends State<RequirementsScreen> {
  final TextEditingController _addController = TextEditingController();
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RequirementProvider>().loadRequirements(
        widget.scholarshipId,
      );
    });
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  Future<void> _handleAddRequirement() async {
    final title = _addController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type a document or task first.')),
      );
      return;
    }

    setState(() => _isAdding = true);
    try {
      final reqProvider = context.read<RequirementProvider>();
      await reqProvider.addRequirement(widget.scholarshipId, title);
      _addController.clear();

      if (mounted) {
        context.read<ScholarshipProvider>().refreshProgressFor(
          widget.scholarshipId,
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e is ArgumentError ? '${e.message}' : 'Failed to add requirement: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _handleEditRequirement(String id, String currentTitle) async {
    final editController = TextEditingController(text: currentTitle);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Requirement'),
        content: TextField(
          controller: editController,
          autofocus: true,
          maxLength: 120,
          decoration: const InputDecoration(
            labelText: 'Requirement Name',
            hintText: 'e.g. Motivation Letter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed == true && editController.text.trim().isNotEmpty && mounted) {
      final reqProvider = context.read<RequirementProvider>();
      await reqProvider.updateRequirementTitle(id, editController.text.trim());
      if (mounted) {
        context.read<ScholarshipProvider>().refreshProgressFor(
          widget.scholarshipId,
        );
      }
    }
  }

  Future<void> _handleDeleteRequirement(String id, String title) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Requirement?',
      content: 'Are you sure you want to delete "$title"?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      final reqProvider = context.read<RequirementProvider>();
      final sProvider = context.read<ScholarshipProvider>();
      final removed = reqProvider.requirements.firstWhere((r) => r.id == id);
      await reqProvider.deleteRequirement(id);
      await sProvider.refreshProgressFor(widget.scholarshipId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"$title" deleted.'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                await reqProvider.restoreRequirement(removed);
                await sProvider.refreshProgressFor(widget.scholarshipId);
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reqProvider = context.watch<RequirementProvider>();
    final sProvider = context.watch<ScholarshipProvider>();

    final scholarship = sProvider.scholarships.firstWhere(
      (s) => s.id == widget.scholarshipId,
      orElse: () => sProvider.scholarships.isNotEmpty
          ? sProvider.scholarships.first
          : const Scholarship(
              id: '',
              name: 'Scholarship',
              country: '',
              deadline: '',
              createdAt: '',
              updatedAt: '',
            ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Requirements Checklist',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              scholarship.name,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.auto_awesome,
              color: AppColors.secondaryTeal,
            ),
            tooltip: 'Generate Checklist with AI',
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.aiAssistant,
                arguments: {'targetScholarshipId': widget.scholarshipId},
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: reqProvider.isLoading
            ? const LoadingView(message: 'Loading checklist...')
            : Column(
                children: [
                  // Progress Card Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ProgressIndicatorCard(
                          completedCount: reqProvider.completedCount,
                          totalCount: reqProvider.totalCount,
                          title: 'Checklist Progress',
                        ),
                        const SizedBox(height: 12),
                        // AI button
                        AppButton(
                          text: 'Generate Checklist with AI',
                          type: AppButtonType.secondary,
                          icon: Icons.auto_awesome,
                          onPressed: () async {
                            await Navigator.of(context).pushNamed(
                              AppRoutes.aiAssistant,
                              arguments: {
                                'targetScholarshipId': widget.scholarshipId,
                              },
                            );
                            if (mounted) {
                              reqProvider.loadRequirements(
                                widget.scholarshipId,
                              );
                              sProvider.refreshProgressFor(
                                widget.scholarshipId,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  // Add Requirement Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _addController,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Add a new document or task...',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _handleAddRequirement(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(48, 48),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isAdding ? null : _handleAddRequirement,
                          child: _isAdding
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Requirements List
                  Expanded(
                    child: reqProvider.requirements.isEmpty
                        ? EmptyState(
                            icon: Icons.checklist_rtl_rounded,
                            title: 'No requirements added yet.',
                            description:
                                'Add the documents and tasks needed for this scholarship.',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: reqProvider.requirements.length,
                            itemBuilder: (context, index) {
                              final req = reqProvider.requirements[index];
                              return RequirementItem(
                                requirement: req,
                                onToggle: (val) async {
                                  await reqProvider.toggleRequirement(
                                    req.id,
                                  );
                                  if (mounted) {
                                    sProvider.refreshProgressFor(
                                      widget.scholarshipId,
                                    );
                                  }
                                },
                                onEdit: () =>
                                    _handleEditRequirement(req.id, req.title),
                                onDelete: () => _handleDeleteRequirement(
                                  req.id,
                                  req.title,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
