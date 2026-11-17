import 'package:intl/intl.dart';

enum DeadlineCategory { urgent, dueSoon, later, overdue, submitted }

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat displayFormat = DateFormat('d MMM yyyy');
  static final DateFormat isoDateFormat = DateFormat('yyyy-MM-dd');

  /// Normalizes a DateTime to start of calendar day (00:00:00).
  static DateTime normalizeToDateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Calculates the difference in full calendar days between two dates.
  /// Positive means targetDate is in the future.
  /// 0 means targetDate is today.
  /// Negative means targetDate is in the past.
  static int daysRemaining(DateTime deadline, {DateTime? referenceDate}) {
    final now = normalizeToDateOnly(referenceDate ?? DateTime.now());
    final target = normalizeToDateOnly(deadline);
    return target.difference(now).inDays;
  }

  /// Categorizes an application deadline based on remaining days and status.
  static DeadlineCategory classifyDeadline({
    required DateTime deadline,
    required String status,
    DateTime? referenceDate,
  }) {
    if (status.trim().toLowerCase() == 'submitted') {
      return DeadlineCategory.submitted;
    }

    final days = daysRemaining(deadline, referenceDate: referenceDate);
    if (days < 0) {
      return DeadlineCategory.overdue;
    } else if (days <= 7) {
      return DeadlineCategory.urgent;
    } else if (days <= 21) {
      return DeadlineCategory.dueSoon;
    } else {
      return DeadlineCategory.later;
    }
  }

  /// Returns user-friendly text for the days remaining or overdue duration.
  static String formatDaysRemaining(
    DateTime deadline, {
    DateTime? referenceDate,
  }) {
    final days = daysRemaining(deadline, referenceDate: referenceDate);
    if (days < 0) {
      final pastDays = days.abs();
      return pastDays == 1 ? '1 day overdue' : '$pastDays days overdue';
    } else if (days == 0) {
      return 'Due today';
    } else if (days == 1) {
      return '1 day left';
    } else {
      return '$days days left';
    }
  }

  /// Formats a DateTime for user display (e.g., '12 Oct 2026').
  static String formatDisplay(DateTime date) {
    return displayFormat.format(date);
  }

  /// Parses an ISO-8601 date string (e.g., '2026-10-12' or full ISO).
  static DateTime parseIso(String isoString) {
    return DateTime.parse(isoString);
  }

  /// Formats a DateTime into an ISO date string (YYYY-MM-DD).
  static String formatIso(DateTime date) {
    return isoDateFormat.format(date);
  }

  /// Calculates notification scheduled time for `offsetDays` before the deadline at 9:00 AM.
  static DateTime? calculateReminderTime({
    required DateTime deadline,
    required int offsetDays,
    DateTime? referenceDate,
  }) {
    final deadlineDate = normalizeToDateOnly(deadline);
    final reminderDate = deadlineDate.subtract(Duration(days: offsetDays));
    final scheduledDateTime = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      9,
      0,
      0,
    );

    final currentNow = referenceDate ?? DateTime.now();
    // Do not schedule a reminder in the past
    if (scheduledDateTime.isBefore(currentNow)) {
      return null;
    }
    return scheduledDateTime;
  }
}
