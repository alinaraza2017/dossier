import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/utils/date_utils.dart';
import '../data/models/scholarship.dart';
import '../data/models/requirement.dart';
import '../data/repositories/scholarship_repository.dart';
import '../data/repositories/requirement_repository.dart';
import '../services/notification_service.dart';

class ScholarshipProvider extends ChangeNotifier {
  final ScholarshipRepository _scholarshipRepo;
  final RequirementRepository _requirementRepo;
  final NotificationService _notificationService;
  static const _uuid = Uuid();

  /// Free plan keeps at most 5 active (non-submitted) applications (§7.1).
  static const int freeActiveLimit = 5;

  List<Scholarship> _scholarships = [];
  Map<String, ({int completed, int total})> _progressMap = {};
  bool _isLoading = false;
  String? _errorMessage;

  ScholarshipProvider({
    ScholarshipRepository? scholarshipRepo,
    RequirementRepository? requirementRepo,
    NotificationService? notificationService,
  })  : _scholarshipRepo = scholarshipRepo ?? ScholarshipRepository(),
        _requirementRepo = requirementRepo ?? RequirementRepository(),
        _notificationService =
            notificationService ?? NotificationService.instance;

  List<Scholarship> get scholarships => _scholarships;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Active (non-submitted) scholarships sorted chronologically
  List<Scholarship> get activeScholarships =>
      _scholarships.where((s) => !s.isSubmitted).toList();

  List<Scholarship> get submittedScholarships =>
      _scholarships.where((s) => s.isSubmitted).toList();

  // Progress lookup
  ({int completed, int total}) getProgressFor(String scholarshipId) {
    return _progressMap[scholarshipId] ?? (completed: 0, total: 0);
  }

  double getProgressFraction(String scholarshipId) {
    final progress = getProgressFor(scholarshipId);
    if (progress.total == 0) return 0.0;
    return (progress.completed / progress.total).clamp(0.0, 1.0);
  }

  int getProgressPercent(String scholarshipId) {
    return (getProgressFraction(scholarshipId) * 100).round();
  }

  // Dashboard Summary Metrics
  int get totalApplicationsCount => _scholarships.length;

  int get urgentApplicationsCount {
    return activeScholarships.where((s) {
      final days = AppDateUtils.daysRemaining(s.deadlineDateTime);
      return days >= 0 && days <= 7;
    }).length;
  }

  int get upcomingDeadlinesCount {
    return activeScholarships.where((s) {
      final days = AppDateUtils.daysRemaining(s.deadlineDateTime);
      return days >= 0 && days <= 21;
    }).length;
  }

  Future<void> loadScholarships() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _scholarships = await _scholarshipRepo.getAll();
      _progressMap = await _requirementRepo.getAllProgressCounts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load scholarships: $e';
      notifyListeners();
    }
  }

  Future<Scholarship> addScholarship(Scholarship scholarship) async {
    try {
      final inserted = await _scholarshipRepo.insert(scholarship);
      await _notificationService.syncRemindersForScholarship(inserted);
      await loadScholarships();
      return inserted;
    } catch (e) {
      _errorMessage = 'Failed to save scholarship: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateScholarship(Scholarship scholarship) async {
    try {
      await _scholarshipRepo.update(scholarship);
      await _notificationService.syncRemindersForScholarship(scholarship);
      await loadScholarships();
    } catch (e) {
      _errorMessage = 'Failed to update scholarship: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateStatus(String id, String newStatus) async {
    try {
      final existing = await _scholarshipRepo.getById(id);
      if (existing != null) {
        final updated = existing.copyWith(status: newStatus);
        await updateScholarship(updated);
      }
    } catch (e) {
      _errorMessage = 'Failed to update status: $e';
      notifyListeners();
    }
  }

  Future<void> toggleReminders(String id, bool remindersOn) async {
    try {
      final existing = await _scholarshipRepo.getById(id);
      if (existing != null) {
        final updated = existing.copyWith(remindersOn: remindersOn);
        await updateScholarship(updated);
      }
    } catch (e) {
      _errorMessage = 'Failed to toggle reminders: $e';
      notifyListeners();
    }
  }

  /// Deletes an application and returns what was removed so the UI can
  /// offer Undo (§18: confirmation, then a 5-second Undo snackbar).
  Future<({Scholarship? scholarship, List<Requirement> requirements})>
      deleteScholarshipWithBackup(String id) async {
    final scholarship = await _scholarshipRepo.getById(id);
    final reqs = await _requirementRepo.getForScholarship(id);
    await deleteScholarship(id);
    return (scholarship: scholarship, requirements: reqs);
  }

  Future<void> restoreScholarship(
      Scholarship scholarship, List<Requirement> requirements) async {
    await _scholarshipRepo.insert(scholarship);
    await _requirementRepo.insertMany(requirements);
    await _notificationService.syncRemindersForScholarship(scholarship);
    await loadScholarships();
  }

  /// Re-applies reminders for every application (after the global
  /// reminders switch changes, §17).
  Future<void> resyncAllReminders({required bool enabled}) async {
    for (final s in _scholarships) {
      if (enabled) {
        await _notificationService.syncRemindersForScholarship(s);
      } else {
        await _notificationService.cancelForScholarship(s.id);
      }
    }
    notifyListeners();
  }

  /// Settings › Clear data on this phone (§17): removes every application,
  /// requirement and scheduled reminder.
  Future<void> clearAllData() async {
    await _notificationService.cancelAll();
    for (final s in List.of(_scholarships)) {
      await _scholarshipRepo.delete(s.id);
    }
    await loadScholarships();
  }

  Future<void> deleteScholarship(String id) async {
    try {
      await _notificationService.cancelForScholarship(id);
      await _scholarshipRepo.delete(id);
      await loadScholarships();
    } catch (e) {
      _errorMessage = 'Failed to delete scholarship: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refreshProgressFor(String scholarshipId) async {
    final counts = await _requirementRepo.getProgressCounts(scholarshipId);
    _progressMap[scholarshipId] = counts;
    notifyListeners();
  }

  /// Gives demo requirements a stable display order.
  List<Requirement> _ordered(List<Requirement> items) => [
        for (var i = 0; i < items.length; i++) items[i].copyWith(sortOrder: i),
      ];

  Future<void> loadSampleData() async {
    final now = DateTime.now().toUtc().toIso8601String();
    final nowDt = DateTime.now();

    final s1Id = _uuid.v4();
    final s1 = await addScholarship(
      Scholarship(
        id: s1Id,
        name: 'Erasmus Mundus',
        country: 'Europe',
        deadline: AppDateUtils.formatIso(nowDt.add(const Duration(days: 5))),
        link: 'https://erasmus-plus.ec.europa.eu',
        status: 'In Progress',
        notes: 'Joint Master Degree with full European scholarship coverage.',
        remindersOn: true,
        createdAt: now,
        updatedAt: now,
      ),
    );

    await _requirementRepo.insertMany(_ordered([
      Requirement(id: _uuid.v4(), scholarshipId: s1.id, title: 'Passport', isDone: true, createdAt: now, updatedAt: now),
      Requirement(id: _uuid.v4(), scholarshipId: s1.id, title: 'IELTS Certificate', isDone: true, createdAt: now, updatedAt: now),
      Requirement(id: _uuid.v4(), scholarshipId: s1.id, title: 'Academic Transcript', isDone: true, createdAt: now, updatedAt: now),
      Requirement(id: _uuid.v4(), scholarshipId: s1.id, title: 'CV', isDone: false, createdAt: now, updatedAt: now),
      Requirement(id: _uuid.v4(), scholarshipId: s1.id, title: 'Motivation Letter', isDone: false, createdAt: now, updatedAt: now),
      Requirement(id: _uuid.v4(), scholarshipId: s1.id, title: 'Recommendation Letter', isDone: false, createdAt: now, updatedAt: now),
    ]));

    final s2Id = _uuid.v4();
    final s2 = await addScholarship(
      Scholarship(
        id: s2Id,
        name: 'DAAD Scholarship',
        country: 'Germany',
        deadline: AppDateUtils.formatIso(nowDt.add(const Duration(days: 15))),
        link: 'https://www.daad.de',
        status: 'In Progress',
        notes: 'Study scholarship for postgraduate courses.',
        remindersOn: true,
        createdAt: now,
        updatedAt: now,
      ),
    );

    await _requirementRepo.insertMany(_ordered([
      Requirement(id: _uuid.v4(), scholarshipId: s2.id, title: 'Application Form', isDone: true, createdAt: now, updatedAt: now),
      Requirement(id: _uuid.v4(), scholarshipId: s2.id, title: 'Curriculum Vitae (Europass)', isDone: true, createdAt: now, updatedAt: now),
      Requirement(id: _uuid.v4(), scholarshipId: s2.id, title: 'Letter of Motivation', isDone: true, createdAt: now, updatedAt: now),
      Requirement(id: _uuid.v4(), scholarshipId: s2.id, title: 'University Degree Certificate', isDone: false, createdAt: now, updatedAt: now),
      Requirement(id: _uuid.v4(), scholarshipId: s2.id, title: 'Certified Transcript', isDone: false, createdAt: now, updatedAt: now),
      Requirement(id: _uuid.v4(), scholarshipId: s2.id, title: 'Language Certificate', isDone: false, createdAt: now, updatedAt: now),
      Requirement(id: _uuid.v4(), scholarshipId: s2.id, title: 'Recommendation Letter 1', isDone: false, createdAt: now, updatedAt: now),
      Requirement(id: _uuid.v4(), scholarshipId: s2.id, title: 'Recommendation Letter 2', isDone: false, createdAt: now, updatedAt: now),
      Requirement(id: _uuid.v4(), scholarshipId: s2.id, title: 'Study Plan', isDone: false, createdAt: now, updatedAt: now),
      Requirement(id: _uuid.v4(), scholarshipId: s2.id, title: 'Proof of Employment / Internship', isDone: false, createdAt: now, updatedAt: now),
    ]));

    final s3Id = _uuid.v4();
    final s3 = await addScholarship(
      Scholarship(
        id: s3Id,
        name: 'Stipendium Hungaricum',
        country: 'Hungary',
        deadline: AppDateUtils.formatIso(nowDt.add(const Duration(days: 30))),
        link: 'https://stipendiumhungaricum.hu',
        status: 'In Progress',
        notes: 'Hungarian Government higher education scholarship.',
        remindersOn: true,
        createdAt: now,
        updatedAt: now,
      ),
    );

    await _requirementRepo.insertMany(_ordered([
      Requirement(id: _uuid.v4(), scholarshipId: s3.id, title: 'Online Application Form', isDone: true, createdAt: now, updatedAt: now),
      Requirement(id: _uuid.v4(), scholarshipId: s3.id, title: 'Motivation Letter', isDone: true, createdAt: now, updatedAt: now),
      Requirement(id: _uuid.v4(), scholarshipId: s3.id, title: 'Proof of Language Proficiency', isDone: true, createdAt: now, updatedAt: now),
      Requirement(id: _uuid.v4(), scholarshipId: s3.id, title: 'School Certificates', isDone: true, createdAt: now, updatedAt: now),
      Requirement(id: _uuid.v4(), scholarshipId: s3.id, title: 'Medical Certificate', isDone: false, createdAt: now, updatedAt: now),
    ]));

    await loadScholarships();
  }
}
