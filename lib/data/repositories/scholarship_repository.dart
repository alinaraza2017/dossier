import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../models/scholarship.dart';

class ScholarshipRepository {
  final AppDatabase _appDatabase;
  static const _uuid = Uuid();

  ScholarshipRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<Database> get _db async => await _appDatabase.database;

  Future<Scholarship> insert(Scholarship scholarship) async {
    final db = await _db;
    final now = DateTime.now().toUtc().toIso8601String();
    final toSave = scholarship.copyWith(
      id: scholarship.id.isEmpty ? _uuid.v4() : scholarship.id,
      createdAt: scholarship.createdAt.isEmpty ? now : scholarship.createdAt,
      updatedAt: now,
    );

    await db.insert(
      'scholarships',
      toSave.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return toSave;
  }

  Future<List<Scholarship>> getAll() async {
    final db = await _db;
    final maps = await db.query(
      'scholarships',
      where: 'deletedAt IS NULL',
      orderBy: 'deadline ASC',
    );
    return maps.map((map) => Scholarship.fromMap(map)).toList();
  }

  Future<Scholarship?> getById(String id) async {
    final db = await _db;
    final maps = await db.query(
      'scholarships',
      where: 'id = ? AND deletedAt IS NULL',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Scholarship.fromMap(maps.first);
  }

  Future<int> update(Scholarship scholarship) async {
    final db = await _db;
    final now = DateTime.now().toUtc().toIso8601String();
    final toSave = scholarship.copyWith(updatedAt: now);
    return await db.update(
      'scholarships',
      toSave.toMap(),
      where: 'id = ?',
      whereArgs: [scholarship.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _db;
    return await db.transaction((txn) async {
      await txn.delete(
        'requirements',
        where: 'scholarshipId = ?',
        whereArgs: [id],
      );
      return await txn.delete('scholarships', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<Scholarship>> getByStatus(String status) async {
    final db = await _db;
    final maps = await db.query(
      'scholarships',
      where: 'status = ? AND deletedAt IS NULL',
      whereArgs: [status],
      orderBy: 'deadline ASC',
    );
    return maps.map((map) => Scholarship.fromMap(map)).toList();
  }

  Future<List<Scholarship>> getUrgent(DateTime maxDeadline) async {
    final db = await _db;
    final maxDateIso = maxDeadline.toIso8601String().split('T')[0];
    final maps = await db.query(
      'scholarships',
      where: "deadline <= ? AND status != 'Submitted' AND deletedAt IS NULL",
      whereArgs: [maxDateIso],
      orderBy: 'deadline ASC',
    );
    return maps.map((map) => Scholarship.fromMap(map)).toList();
  }
}
