import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import 'package:dossier/data/database/app_database.dart';
import 'package:dossier/data/models/scholarship.dart';
import 'package:dossier/data/models/requirement.dart';
import 'package:dossier/data/repositories/scholarship_repository.dart';
import 'package:dossier/data/repositories/requirement_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  databaseFactory = databaseFactoryFfi;

  group('SQLite Database CRUD & Cascade Deletion Tests', () {
    late Database inMemoryDb;
    late ScholarshipRepository scholarshipRepo;
    late RequirementRepository requirementRepo;
    const uuid = Uuid();

    setUp(() async {
      inMemoryDb = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 2,
          onConfigure: (db) async {
            await db.execute('PRAGMA foreign_keys = ON');
          },
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE scholarships (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                country TEXT,
                deadline TEXT NOT NULL,
                link TEXT,
                status TEXT NOT NULL,
                notes TEXT,
                remindersOn INTEGER NOT NULL DEFAULT 1,
                reminderOffsets TEXT,
                reminderTime TEXT,
                isLocked INTEGER NOT NULL DEFAULT 0,
                createdAt TEXT NOT NULL,
                updatedAt TEXT NOT NULL,
                deletedAt TEXT
              )
            ''');

            await db.execute('''
              CREATE TABLE requirements (
                id TEXT PRIMARY KEY,
                scholarshipId TEXT NOT NULL,
                title TEXT NOT NULL,
                isDone INTEGER NOT NULL DEFAULT 0,
                sortOrder INTEGER NOT NULL DEFAULT 0,
                documentId TEXT,
                createdAt TEXT NOT NULL,
                updatedAt TEXT NOT NULL,
                deletedAt TEXT,
                FOREIGN KEY (scholarshipId) REFERENCES scholarships (id) ON DELETE CASCADE
              )
            ''');
          },
        ),
      );

      AppDatabase.instance.setDatabaseForTesting(inMemoryDb);
      scholarshipRepo = ScholarshipRepository(
        appDatabase: AppDatabase.instance,
      );
      requirementRepo = RequirementRepository(
        appDatabase: AppDatabase.instance,
      );
    });

    tearDown(() async {
      await inMemoryDb.close();
    });

    test('1. Insert, retrieve, update, and delete Scholarship', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      final s = Scholarship(
        id: uuid.v4(),
        name: 'Erasmus Mundus',
        country: 'Europe',
        deadline: '2026-10-20',
        status: 'In Progress',
        notes: 'Target joint master programme',
        createdAt: now,
        updatedAt: now,
      );

      final inserted = await scholarshipRepo.insert(s);
      expect(inserted.id.isNotEmpty, isTrue);
      expect(inserted.name, 'Erasmus Mundus');

      final all = await scholarshipRepo.getAll();
      expect(all.length, 1);
      expect(all.first.country, 'Europe');

      final updated = inserted.copyWith(status: 'Ready to Submit');
      await scholarshipRepo.update(updated);

      final fetched = await scholarshipRepo.getById(inserted.id);
      expect(fetched?.status, 'Ready to Submit');

      await scholarshipRepo.delete(inserted.id);
      final afterDelete = await scholarshipRepo.getAll();
      expect(afterDelete.isEmpty, isTrue);
    });

    test(
      '2. Insert requirements, toggle completion, calculate progress and cascade deletion',
      () async {
        final now = DateTime.now().toUtc().toIso8601String();
        final s = await scholarshipRepo.insert(
          Scholarship(
            id: uuid.v4(),
            name: 'DAAD Scholarship',
            country: 'Germany',
            deadline: '2026-11-01',
            createdAt: now,
            updatedAt: now,
          ),
        );

        final reqs = await requirementRepo.insertMany([
          Requirement(id: uuid.v4(), scholarshipId: s.id, title: 'Passport', isDone: true, createdAt: now, updatedAt: now),
          Requirement(id: uuid.v4(), scholarshipId: s.id, title: 'Transcript', isDone: true, createdAt: now, updatedAt: now),
          Requirement(id: uuid.v4(), scholarshipId: s.id, title: 'IELTS Certificate', isDone: true, createdAt: now, updatedAt: now),
          Requirement(id: uuid.v4(), scholarshipId: s.id, title: 'CV', isDone: false, createdAt: now, updatedAt: now),
          Requirement(id: uuid.v4(), scholarshipId: s.id, title: 'Letter of Motivation', isDone: false, createdAt: now, updatedAt: now),
          Requirement(id: uuid.v4(), scholarshipId: s.id, title: 'Recommendation Letter', isDone: false, createdAt: now, updatedAt: now),
        ]);

        expect(reqs.length, 6);

        final progress = await requirementRepo.getProgressCounts(s.id);
        expect(progress.completed, 3);
        expect(progress.total, 6);

        await requirementRepo.toggleComplete(reqs[3].id, true);
        final progressAfterToggle = await requirementRepo.getProgressCounts(s.id);
        expect(progressAfterToggle.completed, 4);

        await scholarshipRepo.delete(s.id);
        final remainingReqs = await requirementRepo.getForScholarship(s.id);
        expect(remainingReqs.isEmpty, isTrue);
      },
    );

    test('3. Progress calculations for 0 requirements', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      final s = await scholarshipRepo.insert(
        Scholarship(
          id: uuid.v4(),
          name: 'Chevening',
          country: 'UK',
          deadline: '2026-11-15',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final progress = await requirementRepo.getProgressCounts(s.id);
      expect(progress.total, 0);
      expect(progress.completed, 0);
    });
  });
}
