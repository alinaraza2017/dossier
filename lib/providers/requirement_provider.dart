import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/requirement.dart';
import '../data/repositories/requirement_repository.dart';

class RequirementProvider extends ChangeNotifier {
  final RequirementRepository _requirementRepo;
  static const _uuid = Uuid();

  String? _currentScholarshipId;
  List<Requirement> _requirements = [];
  bool _isLoading = false;
  String? _errorMessage;

  RequirementProvider({RequirementRepository? requirementRepo})
      : _requirementRepo = requirementRepo ?? RequirementRepository();

  String? get currentScholarshipId => _currentScholarshipId;
  List<Requirement> get requirements => _requirements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalCount => _requirements.length;
  int get completedCount => _requirements.where((r) => r.isDone).length;
  int get remainingCount => totalCount - completedCount;

  double get progressFraction {
    if (totalCount == 0) return 0.0;
    return (completedCount / totalCount).clamp(0.0, 1.0);
  }

  int get progressPercent {
    return (progressFraction * 100).round();
  }

  Future<void> loadRequirements(String scholarshipId) async {
    _currentScholarshipId = scholarshipId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _requirements = await _requirementRepo.getForScholarship(scholarshipId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load requirements: $e';
      notifyListeners();
    }
  }

  Future<void> addRequirement(String scholarshipId, String title) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      throw ArgumentError('Requirement title cannot be empty');
    }
    if (cleanTitle.length > 120) {
      throw ArgumentError('Keep a requirement under 120 characters');
    }
    if (_currentScholarshipId == scholarshipId && _requirements.length >= 50) {
      throw ArgumentError('An application can have up to 50 requirements');
    }

    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final newReq = Requirement(
        id: _uuid.v4(),
        scholarshipId: scholarshipId,
        title: cleanTitle,
        isDone: false,
        sortOrder: _requirements.isEmpty
            ? 0
            : _requirements.map((r) => r.sortOrder).reduce((a, b) => a > b ? a : b) + 1,
        createdAt: now,
        updatedAt: now,
      );
      await _requirementRepo.insert(newReq);
      await loadRequirements(scholarshipId);
    } catch (e) {
      _errorMessage = 'Failed to add requirement: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Adds AI/bulk items to a scholarship. Items that already exist in that
  /// scholarship (same name, ignoring case and spaces) are skipped.
  /// Returns (added, skipped).
  Future<({int added, int skipped})> addManyRequirements(
    String scholarshipId,
    List<String> titles,
  ) async {
    if (titles.isEmpty) return (added: 0, skipped: 0);

    String norm(String t) => t.toLowerCase().replaceAll(RegExp(r'\s+'), '');

    try {
      final existing = await _requirementRepo.getForScholarship(scholarshipId);
      final seen = existing.map((r) => norm(r.title)).toSet();
      final now = DateTime.now().toUtc().toIso8601String();
      int currentOrder = existing.isEmpty
          ? 0
          : existing.map((r) => r.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
      int skipped = 0;
      final reqs = <Requirement>[];
      for (final raw in titles) {
        final t = raw.trim();
        if (t.isEmpty) continue;
        if (!seen.add(norm(t))) {
          skipped++;
          continue;
        }
        reqs.add(Requirement(
          id: _uuid.v4(),
          scholarshipId: scholarshipId,
          title: t.length > 120 ? t.substring(0, 120) : t,
          isDone: false,
          sortOrder: currentOrder++,
          createdAt: now,
          updatedAt: now,
        ));
      }

      await _requirementRepo.insertMany(reqs);
      if (_currentScholarshipId == scholarshipId) {
        await loadRequirements(scholarshipId);
      }
      return (added: reqs.length, skipped: skipped);
    } catch (e) {
      _errorMessage = 'Failed to add requirements: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Re-inserts a deleted requirement (used by the Undo snackbar).
  Future<void> restoreRequirement(Requirement requirement) async {
    await _requirementRepo.insert(requirement);
    if (_currentScholarshipId == requirement.scholarshipId) {
      await loadRequirements(requirement.scholarshipId);
    }
  }

  Future<void> updateRequirementTitle(String id, String newTitle) async {
    final cleanTitle = newTitle.trim();
    if (cleanTitle.isEmpty) return;

    try {
      final existing = _requirements.firstWhere((r) => r.id == id);
      final updated = existing.copyWith(title: cleanTitle);
      await _requirementRepo.update(updated);
      if (_currentScholarshipId != null) {
        await loadRequirements(_currentScholarshipId!);
      }
    } catch (e) {
      _errorMessage = 'Failed to update requirement: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleRequirement(String id) async {
    try {
      final existing = _requirements.firstWhere((r) => r.id == id);
      final newStatus = !existing.isDone;
      await _requirementRepo.toggleComplete(id, newStatus);

      final index = _requirements.indexWhere((r) => r.id == id);
      if (index != -1) {
        _requirements[index] = existing.copyWith(isDone: newStatus);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to toggle requirement: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteRequirement(String id) async {
    try {
      await _requirementRepo.delete(id);
      _requirements.removeWhere((r) => r.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete requirement: $e';
      notifyListeners();
      rethrow;
    }
  }
}
