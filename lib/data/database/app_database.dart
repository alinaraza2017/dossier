import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'database_migrations.dart';

class AppDatabase {
  static const String databaseName = 'dossier_app.db';

  static AppDatabase? _instance;
  Database? _db;

  AppDatabase._();

  static AppDatabase get instance {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  /// Optional factory/setter for injecting custom/mock database instance (for testing).
  void setDatabaseForTesting(Database testDb) {
    _db = testDb;
  }

  Future<Database> get database async {
    if (_db != null && _db!.isOpen) {
      return _db!;
    }
    _db = await initDatabase();
    return _db!;
  }

  Future<Database> initDatabase({String? customPath}) async {
    final path = customPath ?? p.join(await getDatabasesPath(), databaseName);

    return await openDatabase(
      path,
      version: DatabaseMigrations.currentVersion,
      onConfigure: DatabaseMigrations.onConfigure,
      onCreate: DatabaseMigrations.onCreate,
      onUpgrade: DatabaseMigrations.onUpgrade,
    );
  }

  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
