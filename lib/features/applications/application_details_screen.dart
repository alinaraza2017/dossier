import 'package:flutter/material.dart';
import '../../services/local_settings_service.dart';
import '../billing/upgrade_sheet.dart';
import 'package:provider/provider.dart';
import '../../app/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../core/widgets/progress_indicator_card.dart';
import '../../core/widgets/status_chip.dart';
import '../../data/models/scholarship.dart';
import '../../data/models/requirement.dart';
import '../../data/repositories/requirement_repository.dart';
import '../../providers/scholarship_provider.dart';
import '../../services/url_service.dart';
import 'add_application_screen.dart';

class ApplicationDetailsScreen extends StatefulWidget {
  final String scholarshipId;

  const ApplicationDetailsScreen({super.key, required this.scholarshipId});

  @override
  State<ApplicationDetailsScreen> createState() =>
      _ApplicationDetailsScreenState();
}

class _ApplicationDetailsScreenState extends State<ApplicationDetailsScreen> {
  List<Requirement> _previewRequirements = [];
  bool _isLoadingRequirements = false;

  @override
  void initState() {
    super.initState();
    _loadPreviewRequirements();
  }

  Future<void> _loadPreviewRequirements() async {
    setState(() => _isLoadingRequirements = true);
    try {
      final reqs = await RequirementRepository().getForScholarship(
        widget.scholarshipId,
      );
      if (mounted) {
        setState(() {
          _previewRequirements = reqs;
          _isLoadingRequirements = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingRequirements = false);
    }
  }

  Future<void> _handleDelete(Scholarship scholarship) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Application?',
      content:
          'Are you sure you want to delete "${scholarship.name}"? This will permanently delete this scholarship, its associated requirements, and cancel all scheduled reminders.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      final provider = context.read<ScholarshipProvider>();
      final messenger = ScaffoldMessenger.of(context);
      final backup =
          await provider.deleteScholarshipWithBackup(widget.scholarshipId);
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text('"${scholarship.name}" deleted.'),
          duration: const Duration(seconds: 5),
          action: backup.scholarship == null
              ? null
              : SnackBarAction(
                  label: 'Undo',
                  onPressed: () => provider.restoreScholarship(
                    backup.scholarship!,
                    backup.requirements,
                  ),
                ),
        ),
      );
    }
  }

  bool _remindersActive(Scholarship s) =>
      s.remindersOn &&
      !s.isSubmitted &&
      LocalSettingsService.instance.areRemindersEnabled();

  String _reminderLabel(Scholarship s) {
    if (s.isSubmitted) return 'Off (submitted)';
    if (!s.remindersOn) return 'Off for this application';
    if (!LocalSettingsService.instance.areRemindersEnabled()) {
      return 'Off in Settings';
    }
    return '7 and 2 days before, 9:00 AM';
  }

  Future<void> _handleStatusChange(
    Scholarship scholarship,
    String? newStatus,
    ({int completed, int total}) progress,
  ) async {
    if (newStatus == null || newStatus == scholarship.status) return;
    final provider = context.read<ScholarshipProvider>();

    // Re-activating a Submitted application counts toward the Free limit (§18).
    final reactivating = scholarship.isSubmitted && newStatus != 'Submitted';
    if (reactivating &&
        provider.activeScholarships.length >=
            ScholarshipProvider.freeActiveLimit) {
      await UpgradeSheet.show(
        context,
        activeCount: provider.activeScholarships.length,
      );
      return;
    }

    await provider.updateStatus(scholarship.id, newStatus);
    if (!mounted) return;

    // Gentle warning, but still allowed (§7.1 field rules).
    if (newStatus == 'Ready to Submit' && progress.completed < progress.total) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${progress.total - progress.completed} requirement(s) are still incomplete.',
          ),
        ),
      );
    } else if (newStatus == 'Submitted') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marked as Submitted. Its reminders were cancelled.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ScholarshipProvider>();

    final scholarship = provider.scholarships.firstWhere(
      (s) => s.id == widget.scholarshipId,
      orElse: () => const Scholarship(
        id: '',
        name: 'Not Found',
        country: '',
        deadline: '2026-01-01',
        createdAt: '',
        updatedAt: '',
      ),
    );

    if (scholarship.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Scholarship not found.')),
      );
    }

    final deadlineDate = scholarship.deadlineDateTime;
    final category = AppDateUtils.classifyDeadline(
      deadline: deadlineDate,
      status: scholarship.status,
    );
    final daysText = AppDateUtils.formatDaysRemaining(deadlineDate);
    final progress = provider.getProgressFor(scholarship.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(scholarship.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryBlue),
            tooltip: 'Edit Application',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      AddApplicationScreen(scholarshipToEdit: scholarship),
                ),
              );
              _loadPreviewRequirements();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.errorRed),
            tooltip: 'Delete Application',
            onPressed: () => _handleDelete(scholarship),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            scholarship.name,
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                        ),
                        StatusChip.fromDeadlineCategory(
                          category,
                          customLabel: scholarship.isSubmitted
                              ? 'Submitted'
                              : daysText,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.public,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          scholarship.country.isEmpty
                              ? 'No country added'
                              : scholarship.country,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    // Workflow status picker
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status:',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMain,
                          ),
                        ),
                        DropdownButton<String>(
                          value: scholarship.status,
                          underline: const SizedBox(),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.primaryBlue,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Not Started',
                              child: Text('Not Started'),
                            ),
                            DropdownMenuItem(
                              value: 'In Progress',
                              child: Text('In Progress'),
                            ),
                            DropdownMenuItem(
                              value: 'Ready to Submit',
                              child: Text('Ready to Submit'),
                            ),
                            DropdownMenuItem(
                              value: 'Submitted',
                              child: Text('Submitted'),
                            ),
                          ],
                          onChanged: (newStatus) => _handleStatusChange(
                            scholarship,
                            newStatus,
                            progress,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Progress Section Card
              ProgressIndicatorCard(
                completedCount: progress.completed,
                totalCount: progress.total,
                title: 'Application Progress',
              ),
              const SizedBox(height: 16),

              // Requirements Quick Preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Requirements Checklist',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                        Text(
                          '${progress.completed}/${progress.total}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryTeal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_isLoadingRequirements)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else if (_previewRequirements.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No requirements added yet.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      Column(
                        children: _previewRequirements.take(4).map((req) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  req.isDone
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked,
                                  size: 18,
                                  color: req.isDone
                                      ? AppColors.secondaryTeal
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    req.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: req.isDone
                                          ? AppColors.textSecondary
                                          : AppColors.textMain,
                                      decoration: req.isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'View Requirements Checklist',
                      type: AppButtonType.secondary,
                      icon: Icons.checklist_rtl_rounded,
                      onPressed: () async {
                        await Navigator.of(context).pushNamed(
                          AppRoutes.requirements,
                          arguments: scholarship.id,
                        );
                        _loadPreviewRequirements();
                        if (mounted) {
                          provider.refreshProgressFor(scholarship.id);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Details & Links Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Information & Links',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Deadline Detail
                    Row(
                      children: [
                        const Icon(
                          Icons.event_outlined,
                          size: 18,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Deadline: ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          AppDateUtils.formatDisplay(deadlineDate),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Reminder status
                    Row(
                      children: [
                        Icon(
                          _remindersActive(scholarship)
                              ? Icons.notifications_active_outlined
                              : Icons.notifications_off_outlined,
                          size: 18,
                          color: _remindersActive(scholarship)
                              ? AppColors.secondaryTeal
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reminders: ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _reminderLabel(scholarship),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _remindersActive(scholarship)
                                  ? AppColors.secondaryTeal
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Website Link
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.link_rounded,
                          size: 18,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Link: ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Expanded(
                          child:
                              scholarship.link != null &&
                                  scholarship.link!.isNotEmpty
                              ? InkWell(
                                  onTap: () async {
                                    final success = await UrlService.openUrl(
                                      scholarship.link!,
                                    );
                                    if (!success && context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Could not open scholarship link.',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    scholarship.link!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.primaryBlue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                )
                              : Text(
                                  'No link provided',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Notes
                    Text(
                      'Notes:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scholarship.notes != null && scholarship.notes!.isNotEmpty
                          ? scholarship.notes!
                          : 'No notes added.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            scholarship.notes != null &&
                                scholarship.notes!.isNotEmpty
                            ? AppColors.textMain
                            : AppColors.textSecondary,
                        fontStyle:
                            scholarship.notes != null &&
                                scholarship.notes!.isNotEmpty
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
