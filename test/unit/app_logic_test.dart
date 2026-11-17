import 'package:flutter_test/flutter_test.dart';
import 'package:dossier/core/utils/date_utils.dart';
import 'package:dossier/core/utils/validators.dart';
import 'package:dossier/services/ai_service.dart';

void main() {
  group('AppDateUtils Unit Tests', () {
    final referenceDate = DateTime(2026, 10, 12);

    test('1. Deadline today classification (0 days remaining)', () {
      final todayDeadline = DateTime(2026, 10, 12, 18, 30);
      final days = AppDateUtils.daysRemaining(
        todayDeadline,
        referenceDate: referenceDate,
      );
      expect(days, 0);

      final category = AppDateUtils.classifyDeadline(
        deadline: todayDeadline,
        status: 'In Progress',
        referenceDate: referenceDate,
      );
      expect(category, DeadlineCategory.urgent);
      expect(
        AppDateUtils.formatDaysRemaining(
          todayDeadline,
          referenceDate: referenceDate,
        ),
        'Due today',
      );
    });

    test('2. Urgent deadline classification (0 to 7 days remaining)', () {
      final urgentDeadline = DateTime(2026, 10, 17); // 5 days left
      final days = AppDateUtils.daysRemaining(
        urgentDeadline,
        referenceDate: referenceDate,
      );
      expect(days, 5);

      final category = AppDateUtils.classifyDeadline(
        deadline: urgentDeadline,
        status: 'In Progress',
        referenceDate: referenceDate,
      );
      expect(category, DeadlineCategory.urgent);
      expect(
        AppDateUtils.formatDaysRemaining(
          urgentDeadline,
          referenceDate: referenceDate,
        ),
        '5 days left',
      );
    });

    test('3. Due soon deadline classification (8 to 21 days remaining)', () {
      final dueSoonDeadline = DateTime(2026, 10, 27); // 15 days left
      final days = AppDateUtils.daysRemaining(
        dueSoonDeadline,
        referenceDate: referenceDate,
      );
      expect(days, 15);

      final category = AppDateUtils.classifyDeadline(
        deadline: dueSoonDeadline,
        status: 'In Progress',
        referenceDate: referenceDate,
      );
      expect(category, DeadlineCategory.dueSoon);
      expect(
        AppDateUtils.formatDaysRemaining(
          dueSoonDeadline,
          referenceDate: referenceDate,
        ),
        '15 days left',
      );
    });

    test('4. Later deadline classification (22+ days remaining)', () {
      final laterDeadline = DateTime(2026, 11, 12); // 31 days left
      final days = AppDateUtils.daysRemaining(
        laterDeadline,
        referenceDate: referenceDate,
      );
      expect(days, 31);

      final category = AppDateUtils.classifyDeadline(
        deadline: laterDeadline,
        status: 'In Progress',
        referenceDate: referenceDate,
      );
      expect(category, DeadlineCategory.later);
    });

    test('5. Overdue classification (past deadline and not submitted)', () {
      final pastDeadline = DateTime(2026, 10, 5); // 7 days in the past
      final days = AppDateUtils.daysRemaining(
        pastDeadline,
        referenceDate: referenceDate,
      );
      expect(days, -7);

      final category = AppDateUtils.classifyDeadline(
        deadline: pastDeadline,
        status: 'In Progress',
        referenceDate: referenceDate,
      );
      expect(category, DeadlineCategory.overdue);
      expect(
        AppDateUtils.formatDaysRemaining(
          pastDeadline,
          referenceDate: referenceDate,
        ),
        '7 days overdue',
      );
    });

    test(
      '6. Submitted application classification (excluded from urgent/overdue)',
      () {
        // Even if deadline was yesterday, submitted status takes precedence
        final pastDeadline = DateTime(2026, 10, 5);
        final category = AppDateUtils.classifyDeadline(
          deadline: pastDeadline,
          status: 'Submitted',
          referenceDate: referenceDate,
        );
        expect(category, DeadlineCategory.submitted);
      },
    );

    test(
      '7. Notification scheduled time calculation for 7-day and 2-day offsets',
      () {
        final deadline = DateTime(2026, 10, 20); // 8 days from reference
        final reminder7 = AppDateUtils.calculateReminderTime(
          deadline: deadline,
          offsetDays: 7,
          referenceDate: referenceDate,
        );
        expect(reminder7, isNotNull);
        expect(reminder7!.day, 13);
        expect(reminder7.hour, 9);
        expect(reminder7.minute, 0);

        final reminder2 = AppDateUtils.calculateReminderTime(
          deadline: deadline,
          offsetDays: 2,
          referenceDate: referenceDate,
        );
        expect(reminder2, isNotNull);
        expect(reminder2!.day, 18);
        expect(reminder2.hour, 9);

        // Past reminder should return null
        final pastDeadline = DateTime(
          2026,
          10,
          14,
        ); // 7 days prior was Oct 7, before Oct 12 reference
        final pastReminder7 = AppDateUtils.calculateReminderTime(
          deadline: pastDeadline,
          offsetDays: 7,
          referenceDate: referenceDate,
        );
        expect(pastReminder7, isNull);
      },
    );
  });

  group('Validators Unit Tests', () {
    test('8. Empty name and required field validation', () {
      expect(
        Validators.validateRequired('', 'Scholarship name'),
        'Scholarship name is required',
      );
      expect(
        Validators.validateRequired('   ', 'Country'),
        'Country is required',
      );
      expect(
        Validators.validateRequired('Erasmus', 'Scholarship name'),
        isNull,
      );
    });

    test('9. URL validation for HTTP/HTTPS links', () {
      expect(Validators.validateUrl(''), isNull); // Optional
      expect(Validators.validateUrl(null), isNull); // Optional
      expect(Validators.validateUrl('not a url'), isNotNull);
      expect(Validators.validateUrl('ftp://example.com'), isNotNull);
      expect(
        Validators.validateUrl('https://erasmus-plus.ec.europa.eu'),
        isNull,
      );
      expect(Validators.validateUrl('http://daad.de'), isNull);
    });
  });

  group('AI Rule-Based Fallbacks Unit Tests', () {
    final aiService = AiService();

    test(
      '10. Rule-based checklist extraction splits clauses and counts items',
      () async {
        const text =
            'Applicants must provide a valid passport, academic transcript, IELTS certificate, CV, motivation letter and two recommendation letters.';
        final items = await aiService.generateChecklist(text);

        expect(items.length, greaterThanOrEqualTo(6));
        expect(items.any((i) => i.contains('Passport')), isTrue);
        expect(items.any((i) => i.contains('Recommendation Letter 1')), isTrue);
        expect(items.any((i) => i.contains('Recommendation Letter 2')), isTrue);
      },
    );

    test(
      '11. Priority recommendations sorting (nearest deadline first)',
      () async {
        final sampleApps = [
          {
            'id': 1,
            'name': 'Stipendium Hungaricum',
            'daysRemaining': 30,
            'progressPercent': 80,
            'remainingRequirements': 1,
          },
          {
            'id': 2,
            'name': 'Erasmus Mundus',
            'daysRemaining': 5,
            'progressPercent': 50,
            'remainingRequirements': 3,
          },
          {
            'id': 3,
            'name': 'DAAD Scholarship',
            'daysRemaining': 15,
            'progressPercent': 30,
            'remainingRequirements': 7,
          },
        ];

        final priorities = await aiService.generatePriority(
          activeApplications: sampleApps,
        );
        expect(priorities.length, 3);
        expect(priorities[0].scholarshipName, 'Erasmus Mundus');
        expect(priorities[0].rank, 1);
        expect(priorities[1].scholarshipName, 'DAAD Scholarship');
        expect(priorities[2].scholarshipName, 'Stipendium Hungaricum');
      },
    );

    test('12. Progress summary generates informative sentences', () async {
      final sampleApps = [
        {
          'name': 'Erasmus Mundus',
          'daysRemaining': 5,
          'progressPercent': 50,
          'remainingRequirements': 3,
        },
      ];

      final summary = await aiService.generateProgressSummary(
        activeApplications: sampleApps,
      );
      expect(summary.contains('1 active application'), isTrue);
      expect(summary.contains('Erasmus Mundus'), isTrue);
    });
  });
}
