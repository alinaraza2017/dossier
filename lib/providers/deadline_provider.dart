import 'package:flutter/foundation.dart';
import '../core/utils/date_utils.dart';
import '../data/models/scholarship.dart';

enum DeadlineFilter { all, urgent, dueSoon, later, overdue, submitted }

class DeadlineProvider extends ChangeNotifier {
  DeadlineFilter _selectedFilter = DeadlineFilter.all;

  DeadlineFilter get selectedFilter => _selectedFilter;

  void setFilter(DeadlineFilter filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
    }
  }

  /// Filters and sorts scholarships according to the selected filter.
  List<Scholarship> filterScholarships(
    List<Scholarship> allScholarships, {
    DateTime? referenceDate,
  }) {
    final active = allScholarships.where((s) => !s.isSubmitted).toList();
    final submitted = allScholarships.where((s) => s.isSubmitted).toList();

    // Sort active scholarships chronologically (nearest deadline first)
    active.sort((a, b) => a.deadlineDateTime.compareTo(b.deadlineDateTime));
    submitted.sort((a, b) => a.deadlineDateTime.compareTo(b.deadlineDateTime));

    switch (_selectedFilter) {
      case DeadlineFilter.all:
        return [...active, ...submitted];

      case DeadlineFilter.urgent:
        return active.where((s) {
          final days = AppDateUtils.daysRemaining(
            s.deadlineDateTime,
            referenceDate: referenceDate,
          );
          return days >= 0 && days <= 7;
        }).toList();

      case DeadlineFilter.dueSoon:
        return active.where((s) {
          final days = AppDateUtils.daysRemaining(
            s.deadlineDateTime,
            referenceDate: referenceDate,
          );
          return days >= 8 && days <= 21;
        }).toList();

      case DeadlineFilter.later:
        return active.where((s) {
          final days = AppDateUtils.daysRemaining(
            s.deadlineDateTime,
            referenceDate: referenceDate,
          );
          return days >= 22;
        }).toList();

      case DeadlineFilter.overdue:
        return active.where((s) {
          final days = AppDateUtils.daysRemaining(
            s.deadlineDateTime,
            referenceDate: referenceDate,
          );
          return days < 0;
        }).toList();

      case DeadlineFilter.submitted:
        return submitted;
    }
  }
}
