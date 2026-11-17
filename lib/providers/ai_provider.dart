import 'package:flutter/foundation.dart';
import '../core/utils/date_utils.dart';
import '../data/models/scholarship.dart';
import '../services/ai_service.dart';

class AiProvider extends ChangeNotifier {
  final AiService _aiService;

  // Feature 1: Checklist Generator state
  bool _isLoadingChecklist = false;
  List<String> _generatedChecklist = [];
  String? _checklistError;

  // Feature 2: Priority Recommendations state
  bool _isLoadingPriority = false;
  List<AiPriorityItem> _priorityResults = [];
  String? _priorityError;

  // Feature 3: Progress Summary state
  bool _isLoadingSummary = false;
  String? _summaryResult;
  String? _summaryError;

  AiProvider({AiService? aiService}) : _aiService = aiService ?? AiService();

  // Getters
  bool get isLoadingChecklist => _isLoadingChecklist;
  List<String> get generatedChecklist => _generatedChecklist;
  String? get checklistError => _checklistError;

  bool get isLoadingPriority => _isLoadingPriority;
  List<AiPriorityItem> get priorityResults => _priorityResults;
  String? get priorityError => _priorityError;

  bool get isLoadingSummary => _isLoadingSummary;
  String? get summaryResult => _summaryResult;
  String? get summaryError => _summaryError;

  bool get isAiConfigured => _aiService.isConfigured;

  // ==========================================
  // Feature 1: Checklist actions
  // ==========================================
  Future<void> generateChecklist(String text) async {
    _isLoadingChecklist = true;
    _checklistError = null;
    notifyListeners();

    try {
      final items = await _aiService.generateChecklist(text);
      _generatedChecklist = items;
      _isLoadingChecklist = false;
      notifyListeners();
    } catch (e) {
      _isLoadingChecklist = false;
      _checklistError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void removeChecklistItem(int index) {
    if (index >= 0 && index < _generatedChecklist.length) {
      _generatedChecklist.removeAt(index);
      notifyListeners();
    }
  }

  void editChecklistItem(int index, String newTitle) {
    final clean = newTitle.trim();
    if (clean.isNotEmpty && index >= 0 && index < _generatedChecklist.length) {
      _generatedChecklist[index] = clean;
      notifyListeners();
    }
  }

  void addChecklistItem(String title) {
    final clean = title.trim();
    if (clean.isNotEmpty) {
      _generatedChecklist.add(clean);
      notifyListeners();
    }
  }

  void clearChecklist() {
    _generatedChecklist = [];
    _checklistError = null;
    notifyListeners();
  }

  // ==========================================
  // Feature 2: Priority recommendations
  // ==========================================
  Future<void> generatePriority({
    required List<Scholarship> activeScholarships,
    required Map<String, ({int completed, int total})> progressMap,
  }) async {
    _isLoadingPriority = true;
    _priorityError = null;
    notifyListeners();

    try {
      final payload = activeScholarships.map((s) {
        final days = AppDateUtils.daysRemaining(s.deadlineDateTime);
        final counts = progressMap[s.id] ?? (completed: 0, total: 0);
        final percent = counts.total == 0
            ? 0
            : ((counts.completed / counts.total) * 100).round();
        final remaining = counts.total - counts.completed;

        return {
          'id': s.id,
          'name': s.name,
          'daysRemaining': days,
          'progressPercent': percent,
          'remainingRequirements': remaining < 0 ? 0 : remaining,
        };
      }).toList();

      final results = await _aiService.generatePriority(
        activeApplications: payload,
      );
      _priorityResults = results;
      _isLoadingPriority = false;
      notifyListeners();
    } catch (e) {
      _isLoadingPriority = false;
      _priorityError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  // ==========================================
  // Feature 3: Progress summary
  // ==========================================
  Future<void> generateProgressSummary({
    required List<Scholarship> activeScholarships,
    required Map<String, ({int completed, int total})> progressMap,
  }) async {
    _isLoadingSummary = true;
    _summaryError = null;
    notifyListeners();

    try {
      final payload = activeScholarships.map((s) {
        final days = AppDateUtils.daysRemaining(s.deadlineDateTime);
        final counts = progressMap[s.id] ?? (completed: 0, total: 0);
        final percent = counts.total == 0
            ? 0
            : ((counts.completed / counts.total) * 100).round();
        final remaining = counts.total - counts.completed;

        return {
          'name': s.name,
          'daysRemaining': days,
          'progressPercent': percent,
          'remainingRequirements': remaining < 0 ? 0 : remaining,
        };
      }).toList();

      final summary = await _aiService.generateProgressSummary(
        activeApplications: payload,
      );
      _summaryResult = summary;
      _isLoadingSummary = false;
      notifyListeners();
    } catch (e) {
      _isLoadingSummary = false;
      _summaryError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }
}
