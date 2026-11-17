import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/shared_design_widgets.dart';

class AiAssistantScreen extends StatefulWidget {
  final String? initialTargetScholarshipId;

  const AiAssistantScreen({super.key, this.initialTargetScholarshipId});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _pasteController = TextEditingController(
    text:
        'Applicants must provide a valid passport, academic transcript, IELTS certificate, CV, motivation letter and two recommendation letters.',
  );

  final List<String> _checklistItems = const [
    'Passport',
    'Academic Transcript',
    'IELTS Certificate',
    'CV',
    'Motivation Letter',
    'Recommendation Letter 1',
    'Recommendation Letter 2',
  ];

  final Set<String> _checkedItems = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkedItems.addAll(_checklistItems);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pasteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Header (Fig 13.8 & 13.9)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
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
                      Icon(Icons.auto_awesome, color: AppColors.secondaryTeal, size: 20),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Smart help for your applications',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pill Tab Selector (Fig 13.8 & 13.9)
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

            const SizedBox(height: 12),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildChecklistTab(),
                  _buildPrioritySummaryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 1: CHECKLIST GENERATOR (Fig 13.8)
  Widget _buildChecklistTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        const Text(
          'Paste scholarship requirements',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 8),

        AppCard(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _pasteController,
            maxLines: 4,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
            decoration: const InputDecoration.collapsed(
              hintText: 'Paste scholarship document requirement text here...',
            ),
          ),
        ),

        const SizedBox(height: 14),

        OutlineButton(
          icon: Icons.auto_awesome,
          label: 'Generate Checklist',
          borderColor: AppColors.secondaryTeal,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Generating checklist with AI...')),
            );
          },
        ),

        const SizedBox(height: 18),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Generated checklist',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.bold),
            ),
            Text(
              '${_checklistItems.length} items',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Generated items card
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: _checklistItems.map((item) {
              final isChecked = _checkedItems.contains(item);
              final isLast = item == _checklistItems.last;
              return Column(
                children: [
                  ListTile(
                    dense: true,
                    leading: Icon(
                      isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                      color: isChecked ? AppColors.secondaryTeal : AppColors.textSecondary,
                      size: 20,
                    ),
                    title: Text(
                      item,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                    ),
                    onTap: () {
                      setState(() {
                        if (isChecked) {
                          _checkedItems.remove(item);
                        } else {
                          _checkedItems.add(item);
                        }
                      });
                    },
                  ),
                  if (!isLast) const Divider(height: 1, indent: 48),
                ],
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        PrimaryButton(
          label: 'Add to Erasmus Mundus',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Checklist added to Erasmus Mundus!')),
            );
          },
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.info_outline, size: 12, color: AppColors.textSecondary),
            SizedBox(width: 4),
            Text(
              'Pro trial: up to 300 AI uses a month · 12 used',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // TAB 2: PRIORITY & SUMMARY (Fig 13.9)
  Widget _buildPrioritySummaryTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        OutlineButton(
          icon: Icons.auto_awesome,
          label: 'Analyze My Applications',
          borderColor: AppColors.secondaryTeal,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Analyzing priority order with AI...')),
            );
          },
        ),

        const SizedBox(height: 20),

        const Text(
          'Recommended order',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Recommended Order List (Fig 13.9)
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildPriorityItem(
                rank: '1',
                rankColor: AppColors.errorRed,
                title: 'Erasmus Mundus',
                subtitle: '5 days left · 50% complete',
                tagLabel: 'Do first',
                tagBg: AppColors.chipUrgentBg,
                tagText: AppColors.chipUrgentText,
              ),
              const Divider(height: 1, indent: 48),
              _buildPriorityItem(
                rank: '2',
                rankColor: AppColors.warningAmber,
                title: 'DAAD Scholarship',
                subtitle: '15 days left · 30% complete',
                tagLabel: 'Next',
                tagBg: AppColors.chipDueSoonBg,
                tagText: AppColors.chipDueSoonText,
              ),
              const Divider(height: 1, indent: 48),
              _buildPriorityItem(
                rank: '3',
                rankColor: AppColors.primaryBlue,
                title: 'Stipendium Hungaricum',
                subtitle: '30 days left · 80% complete',
                tagLabel: 'Later',
                tagBg: AppColors.chipLaterBg,
                tagText: AppColors.chipLaterText,
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Why this order card (Fig 13.9)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F6F4),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.secondaryTeal, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Why this order',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryTeal,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                'Erasmus Mundus has the closest deadline and three requirements are still incomplete.',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textMain),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Progress summary card (Fig 13.9)
        AppCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Progress summary',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'You have 3 active applications. Erasmus Mundus is the most urgent and has 3 incomplete requirements.',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.info_outline, size: 12, color: AppColors.textSecondary),
            SizedBox(width: 4),
            Text(
              'Tap an application to open it · Last updated 9:40 AM',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPriorityItem({
    required String rank,
    required Color rankColor,
    required String title,
    required String subtitle,
    required String tagLabel,
    required Color tagBg,
    required Color tagText,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 12,
        backgroundColor: rankColor,
        child: Text(
          rank,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: tagBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          tagLabel,
          style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.bold, color: tagText),
        ),
      ),
    );
  }
}
