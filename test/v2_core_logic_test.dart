import 'package:flutter_test/flutter_test.dart';
import 'package:dossier/data/models/scholarship.dart';
import 'package:dossier/data/models/requirement.dart';
import 'package:dossier/services/entitlement_service.dart';

void main() {
  group('Progress & Days Left Calculation Tests', () {
    test('Calculates progress percentage accurately', () {
      final requirements = [
        Requirement(id: '1', scholarshipId: 's1', title: 'Passport', isDone: true, createdAt: '', updatedAt: ''),
        Requirement(id: '2', scholarshipId: 's1', title: 'IELTS', isDone: true, createdAt: '', updatedAt: ''),
        Requirement(id: '3', scholarshipId: 's1', title: 'Transcript', isDone: true, createdAt: '', updatedAt: ''),
        Requirement(id: '4', scholarshipId: 's1', title: 'CV', isDone: false, createdAt: '', updatedAt: ''),
        Requirement(id: '5', scholarshipId: 's1', title: 'Motivation Letter', isDone: false, createdAt: '', updatedAt: ''),
        Requirement(id: '6', scholarshipId: 's1', title: 'Recommendation Letter', isDone: false, createdAt: '', updatedAt: ''),
      ];

      final doneCount = requirements.where((r) => r.isDone).length;
      final progress = (doneCount / requirements.length) * 100;

      expect(doneCount, 3);
      expect(requirements.length, 6);
      expect(progress.round(), 50);
    });

    test('Effective reminder offsets fallback to 7, 2 days for Free', () {
      final freeScholarship = Scholarship(
        id: 's1',
        name: 'Erasmus',
        deadline: '2026-10-12',
        createdAt: '',
        updatedAt: '',
      );

      expect(freeScholarship.effectiveOffsets, [7, 2]);

      final proScholarship = Scholarship(
        id: 's2',
        name: 'DAAD',
        deadline: '2026-10-22',
        reminderOffsets: '14,7,2,1',
        createdAt: '',
        updatedAt: '',
      );

      expect(proScholarship.effectiveOffsets, [14, 7, 2, 1]);
    });
  });

  group('Entitlement State Machine Tests (§16.5)', () {
    test('Identifies active Pro states properly', () {
      final trialState = EntitlementState(
        status: EntitlementStatus.trial,
        lastVerifiedAt: DateTime.now(),
      );
      expect(trialState.isPro, true);

      final proActiveState = EntitlementState(
        status: EntitlementStatus.proActive,
        lastVerifiedAt: DateTime.now(),
      );
      expect(proActiveState.isPro, true);

      final gracePeriodState = EntitlementState(
        status: EntitlementStatus.gracePeriod,
        lastVerifiedAt: DateTime.now(),
      );
      expect(gracePeriodState.isPro, true);

      final expiredState = EntitlementState(
        status: EntitlementStatus.expired,
        lastVerifiedAt: DateTime.now(),
      );
      expect(expiredState.isPro, false);

      final holdState = EntitlementState(
        status: EntitlementStatus.accountHold,
        lastVerifiedAt: DateTime.now(),
      );
      expect(holdState.isPro, false);
    });
  });

  group('Free 5-Active Limit & Downgrade Logic Tests (§15.1, §16.7)', () {
    test('Active count excludes submitted applications', () {
      final list = [
        Scholarship(id: '1', name: 'App 1', deadline: '2026-11-01', status: 'In Progress', createdAt: '', updatedAt: ''),
        Scholarship(id: '2', name: 'App 2', deadline: '2026-11-02', status: 'Not Started', createdAt: '', updatedAt: ''),
        Scholarship(id: '3', name: 'App 3', deadline: '2026-11-03', status: 'In Progress', createdAt: '', updatedAt: ''),
        Scholarship(id: '4', name: 'App 4', deadline: '2026-11-04', status: 'Ready to Submit', createdAt: '', updatedAt: ''),
        Scholarship(id: '5', name: 'App 5', deadline: '2026-11-05', status: 'In Progress', createdAt: '', updatedAt: ''),
        Scholarship(id: '6', name: 'App 6', deadline: '2026-11-06', status: 'Submitted', createdAt: '', updatedAt: ''),
      ];

      final activeCount = list.where((a) => a.isActive).length;
      expect(activeCount, 5); // 5 active, 1 submitted (within Free 5 limit)
    });
  });
}
