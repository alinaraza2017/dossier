import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:dossier/core/utils/validators.dart';
import 'package:dossier/data/database/app_database.dart';
import 'package:dossier/data/database/database_migrations.dart';
import 'package:dossier/data/models/scholarship.dart';
import 'package:dossier/data/repositories/requirement_repository.dart';
import 'package:dossier/data/repositories/scholarship_repository.dart';
import 'package:dossier/providers/requirement_provider.dart';
import 'package:dossier/providers/scholarship_provider.dart';
import 'package:dossier/services/export_service.dart';

/// Rules from the project document (§7.1, §7.2, §14.1, §17).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  databaseFactory = databaseFactoryFfi;

  group('Field rules (§7.1)', () {
    test('Name must be 2 to 80 characters', () {
      expect(Validators.validateName(''), isNotNull);
      expect(Validators.validateName('A'), isNotNull);
      expect(Validators.validateName('AB'), isNull);
      expect(Validators.validateName('x' * 81), isNotNull);
    });

    test('Country is optional, max 60 characters', () {
      expect(Validators.validateCountry(''), isNull);
      expect(Validators.validateCountry('Germany'), isNull);
      expect(Validators.validateCountry('x' * 61), isNotNull);
    });

    test('Link gets https:// added automatically', () {
      expect(Validators.normalizeUrl('daad.de'), 'https://daad.de');
      expect(Validators.normalizeUrl('http://hec.gov.pk'), 'http://hec.gov.pk');
      expect(Validators.validateUrl('www.hec.gov.pk'), isNull);
      expect(Validators.validateUrl('not a link'), isNotNull);
      expect(Validators.validateUrl('ftp://files.example.com'), isNotNull);
    });

    test('Free plan limit is 5 active applications', () {
      expect(ScholarshipProvider.freeActiveLimit, 5);
    });
  });

  group('Requirements and export', () {
    late Database db;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: DatabaseMigrations.currentVersion,
          onConfigure: DatabaseMigrations.onConfigure,
          onCreate: DatabaseMigrations.onCreate,
        ),
      );
      AppDatabase.instance.setDatabaseForTesting(db);
    });

    tearDown(() async => db.close());

    Future<Scholarship> addScholarship() {
      return ScholarshipRepository().insert(const Scholarship(
        id: '',
        name: 'Erasmus Mundus',
        country: 'Europe',
        deadline: '2026-12-01',
        createdAt: '',
        updatedAt: '',
      ));
    }

    test('AI checklist skips items that already exist (§14.1)', () async {
      final s = await addScholarship();
      final provider = RequirementProvider();

      final first =
          await provider.addManyRequirements(s.id, ['Passport', 'CV']);
      expect(first.added, 2);
      expect(first.skipped, 0);

      final second = await provider
          .addManyRequirements(s.id, ['passport ', 'C V', 'IELTS Certificate']);
      expect(second.added, 1);
      expect(second.skipped, 2);

      final all = await RequirementRepository().getForScholarship(s.id);
      expect(all.map((r) => r.title).toList(),
          ['Passport', 'CV', 'IELTS Certificate']); // insertion order kept
    });

    test('CSV export escapes commas and quotes', () async {
      final s = await addScholarship();
      await RequirementProvider()
          .addManyRequirements(s.id, ['Letter, "signed"']);
      final csv = await ExportService.buildCsv([s]);
      final lines = csv.trim().split('\n');
      expect(lines.first.startsWith('Scholarship,Country,Deadline'), isTrue);
      expect(lines[1], contains('"Letter, ""signed"""'));
    });
  });
}
