import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../models/requirement.dart';

class RequirementRepository {
  final AppDatabase _appDatabase;
  static const _uuid = Uuid();

  RequirementRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<Database> get _db async => await _appDatabase.database;

  Future<Requirement> insert(Requirement requirement) async {
    final db = await _db;
    final now = DateTime.now().toUtc().toIso8601String();
    final toSave = requirement.copyWith(
      id: requirement.id.isEmpty ? _uuid.v4() : requirement.id,
      createdAt: requirement.createdAt.isEmpty ? now : requirement.createdAt,
      updatedAt: now,
    );

    await db.insert(
      'requirements',
      toSave.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return toSave;
  }

  Future<List<Requirement>> insertMany(List<Requirement> requirements) async {
    if (requirements.isEmpty) return [];

    final db = await _db;
    final insertedList = <Requirement>[];
    final now = DateTime.now().toUtc().toIso8601String();

    await db.transaction((txn) async {
      for (final req in requirements) {
        final toSave = req.copyWith(
          id: req.id.isEmpty ? _uuid.v4() : req.id,
          createdAt: req.createdAt.isEmpty ? now : req.createdAt,
          updatedAt: now,
        );
        await txn.insert(
          'requirements',
          toSave.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        insertedList.add(toSave);
      }
    });

    return insertedList;
  }

  Future<List<Requirement>> getForScholarship(String scholarshipId) async {
    final db = await _db;
    final maps = await db.query(
      'requirements',
      where: 'scholarshipId = ? AND deletedAt IS NULL',
      whereArgs: [scholarshipId],
      orderBy: 'sortOrder ASC, createdAt ASC, rowid ASC',
    );
    return maps.map((map) => Requirement.fromMap(map)).toList();
  }

  Future<int> update(Requirement requirement) async {
    final db = await _db;
    final now = DateTime.now().toUtc().toIso8601String();
    final toSave = requirement.copyWith(updatedAt: now);
    return await db.update(
      'requirements',
      toSave.toMap(),
      where: 'id = ?',
      whereArgs: [requirement.id],
    );
  }

  Future<int> toggleComplete(String id, bool isDone) async {
    final db = await _db;
    final now = DateTime.now().toUtc().toIso8601String();
    return await db.update(
      'requirements',
      {
        'isDone': isDone ? 1 : 0,
        'updatedAt': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _db;
    return await db.delete(
      'requirements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteForScholarship(String scholarshipId) async {
    final db = await _db;
    return await db.delete(
      'requirements',
      where: 'scholarshipId = ?',
      whereArgs: [scholarshipId],
    );
  }

  Future<({int completed, int total})> getProgressCounts(String scholarshipId) async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN isDone = 1 THEN 1 ELSE 0 END) as completed
      FROM requirements
      WHERE scholarshipId = ? AND deletedAt IS NULL
    ''', [scholarshipId]);

    if (results.isEmpty) return (completed: 0, total: 0);
    final row = results.first;
    final total = (row['total'] as int?) ?? 0;
    final completed = (row['completed'] as int?) ?? 0;
    return (completed: completed, total: total);
  }

  Future<Map<String, ({int completed, int total})>> getAllProgressCounts() async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT 
        scholarshipId,
        COUNT(*) as total,
        SUM(CASE WHEN isDone = 1 THEN 1 ELSE 0 END) as completed
      FROM requirements
      WHERE deletedAt IS NULL
      GROUP BY scholarshipId
    ''');

    final map = <String, ({int completed, int total})>{};
    for (final row in results) {
      final sId = row['scholarshipId']?.toString();
      if (sId != null) {
        final total = (row['total'] as int?) ?? 0;
        final completed = (row['completed'] as int?) ?? 0;
        map[sId] = (completed: completed, total: total);
      }
    }
    return map;
  }
}
