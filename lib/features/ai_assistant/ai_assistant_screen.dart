import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/ai_provider.dart';
import 'checklist_tab.dart';
import 'priority_summary_tab.dart';

/// AI Assistant (Fig 13.8 & 13.9): three focused features, no open chat.
/// Tab 1: checklist generator. Tab 2: priority order + progress summary.
class AiAssistantScreen extends StatefulWidget {
  final String? initialTargetScholarshipId;

  const AiAssistantScreen({super.key, this.initialTargetScholarshipId});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // When opened from a Requirements screen this is a pushed route,
    // so it needs its own back arrow (as a bottom tab it does not).
    final canPop = Navigator.of(context).canPop();
    final aiConfigured = context.watch<AiProvider>().isAiConfigured;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: canPop
          ? AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: SafeArea(
        top: !canPop,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, canPop ? 0 : 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        'AI Assistant',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.auto_awesome,
                          color: AppColors.secondaryTeal, size: 20),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    aiConfigured
                        ? 'Checklist, priority and summary · Gemini AI'
                        : 'Checklist, priority and summary · offline mode',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 44,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Checklist'),
                        Tab(text: 'Priority & Summary'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ChecklistTab(
                    initialTargetScholarshipId:
                        widget.initialTargetScholarshipId,
                  ),
                  const PrioritySummaryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
