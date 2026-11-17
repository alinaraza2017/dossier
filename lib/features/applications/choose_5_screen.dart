import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/shared_design_widgets.dart';

class Choose5Screen extends StatefulWidget {
  final List<Map<String, dynamic>> applications;

  const Choose5Screen({super.key, required this.applications});

  @override
  State<Choose5Screen> createState() => _Choose5ScreenState();
}

class _Choose5ScreenState extends State<Choose5Screen> {
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    // Pre-select first 5 (nearest deadlines)
    for (int i = 0; i < widget.applications.length && i < 5; i++) {
      _selectedIds.add(widget.applications[i]['id'] as String);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            const Text(
              'Choose 5 to keep active',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'You are back on Free. Pick the 5 applications you are working on. The others stay saved as read-only, and their 7 and 2 day reminders still work.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active applications',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlueSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_selectedIds.length} of 5 selected',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Selectable List (Fig 13.19)
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: widget.applications.map((app) {
                  final id = app['id'] as String;
                  final isSelected = _selectedIds.contains(id);
                  final isLast = app == widget.applications.last;

                  return Column(
                    children: [
                      ListTile(
                        leading: Checkbox(
                          value: isSelected,
                          activeColor: AppColors.secondaryTeal,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                if (_selectedIds.length < 5) {
                                  _selectedIds.add(id);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Free plan allows up to 5 active applications.')),
                                  );
                                }
                              } else {
                                _selectedIds.remove(id);
                              }
                            });
                          },
                        ),
                        title: Text(
                          app['name'] as String,
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${app['deadline']} · ${app['progress']}%',
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
                        ),
                        trailing: !isSelected
                            ? const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 18)
                            : null,
                      ),
                      if (!isLast) const Divider(height: 1, indent: 56),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Submitted applications never count toward the limit.',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            PrimaryButton(
              label: 'Keep these 5',
              onPressed: _selectedIds.isNotEmpty
                  ? () {
                      Navigator.pop(context, _selectedIds);
                    }
                  : null,
            ),

            const SizedBox(height: 10),

            Center(
              child: TextButton(
                onPressed: () {
                  // Subscribe opens paywall
                },
                child: const Text(
                  'Subscribe to keep all',
                  style: TextStyle(fontFamily: 'Poppins', color: AppColors.primaryBlue, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
