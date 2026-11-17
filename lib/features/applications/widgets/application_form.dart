import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/scholarship.dart';
import 'application_status_selector.dart';

class ApplicationForm extends StatefulWidget {
  final Scholarship? initialScholarship;
  final Future<void> Function(Scholarship scholarship) onSave;

  const ApplicationForm({
    super.key,
    this.initialScholarship,
    required this.onSave,
  });

  @override
  State<ApplicationForm> createState() => _ApplicationFormState();
}

class _ApplicationFormState extends State<ApplicationForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _countryController;
  late TextEditingController _linkController;
  late TextEditingController _notesController;

  late DateTime _selectedDeadline;
  late String _status;
  late bool _remindersOn;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.initialScholarship;

    _nameController = TextEditingController(text: s?.name ?? '');
    _countryController = TextEditingController(text: s?.country ?? '');
    _linkController = TextEditingController(text: s?.link ?? '');
    _notesController = TextEditingController(text: s?.notes ?? '');

    _selectedDeadline = s != null
        ? s.deadlineDateTime
        : DateTime.now().add(const Duration(days: 30));
    _status = s?.status ?? 'Not Started';
    _remindersOn = s?.remindersOn ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _linkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.textMain,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_isSaving) return; // Prevent double taps

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final scholarship = Scholarship(
        id: widget.initialScholarship?.id ?? '',
        name: _nameController.text.trim(),
        country: _countryController.text.trim(),
        deadline: AppDateUtils.formatIso(_selectedDeadline),
        link: _linkController.text.trim().isEmpty
            ? null
            : _linkController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        status: _status,
        remindersOn: _remindersOn,
        createdAt:
            widget.initialScholarship?.createdAt ?? now,
        updatedAt: now,
      );

      await widget.onSave(scholarship);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scholarship Name
          AppTextField(
            label: 'Scholarship Name *',
            hint: 'e.g. Erasmus Mundus, Chevening, Fulbright',
            controller: _nameController,
            validator: (val) =>
                Validators.validateRequired(val, 'Scholarship name'),
          ),
          const SizedBox(height: 16),

          // Country or Region
          AppTextField(
            label: 'Country or Region *',
            hint: 'e.g. Europe, United Kingdom, USA, Germany',
            controller: _countryController,
            validator: (val) =>
                Validators.validateRequired(val, 'Country or region'),
          ),
          const SizedBox(height: 16),

          // Deadline Picker Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Application Deadline *',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppDateUtils.formatDisplay(_selectedDeadline),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 20,
                        color: AppColors.primaryBlue,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Application Link
          AppTextField(
            label: 'Application Link (Optional)',
            hint: 'https://scholarship-portal.example.com',
            controller: _linkController,
            keyboardType: TextInputType.url,
            validator: Validators.validateUrl,
            prefixIcon: const Icon(
              Icons.link,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Status Selector
          ApplicationStatusSelector(
            selectedStatus: _status,
            onStatusChanged: (newStatus) {
              setState(() => _status = newStatus);
            },
          ),
          const SizedBox(height: 16),

          // Notes
          AppTextField(
            label: 'Notes & Application Tips (Optional)',
            hint:
                'e.g. Requires 2 reference letters from university professors...',
            controller: _notesController,
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Reminder Switch Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deadline Reminders',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Receive local notifications 7 days and 2 days before deadline at 9:00 AM.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _remindersOn,
                  onChanged: (val) {
                    setState(() => _remindersOn = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Save Button
          AppButton(
            text: widget.initialScholarship == null
                ? 'Save Application'
                : 'Update Application',
            onPressed: _handleSubmit,
            isLoading: _isSaving,
          ),
        ],
      ),
    );
  }
}
