import 'package:flutter_test/flutter_test.dart';
import 'package:dossier/services/ai_service.dart';

/// Offline checklist extraction must return clean item names (§14.1).
void main() {
  final ai = AiService();

  test('Document example input gives the document example output', () async {
    final items = await ai.generateChecklist(
      'Applicants must provide a valid passport, academic transcript, IELTS certificate, CV, motivation letter and two recommendation letters.',
    );
    expect(items, [
      'Passport',
      'Academic Transcript',
      'IELTS Certificate',
      'CV',
      'Motivation Letter',
      'Recommendation Letter 1',
      'Recommendation Letter 2',
    ]);
  });

  test('Lead-in phrases are removed from other wording', () async {
    final items = await ai.generateChecklist(
      'Applicants must submit a CV, a passport copy, a bank statement and two recommendation letters.',
    );
    expect(items, [
      'CV',
      'Passport Copy',
      'Bank Statement',
      'Recommendation Letter 1',
      'Recommendation Letter 2',
    ]);
  });

  test('"You need" sentences are cleaned too', () async {
    final items = await ai.generateChecklist(
      'You need a birth certificate, bank statement and a police clearance letter.',
    );
    expect(items, ['Birth Certificate', 'Bank Statement', 'Police Clearance Letter']);
  });

  test('Priority works with UUID string ids and nearest deadline first', () async {
    final items = await ai.generatePriority(activeApplications: [
      {'id': 'b-uuid', 'name': 'DAAD', 'daysRemaining': 15, 'progressPercent': 30, 'remainingRequirements': 7},
      {'id': 'a-uuid', 'name': 'Erasmus', 'daysRemaining': 5, 'progressPercent': 50, 'remainingRequirements': 3},
    ]);
    expect(items.first.scholarshipName, 'Erasmus');
    expect(items.first.scholarshipId, 'a-uuid');
    expect(items.first.rank, 1);
  });
}
