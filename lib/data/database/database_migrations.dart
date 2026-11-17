import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class DatabaseMigrations {
  DatabaseMigrations._();

  static const int currentVersion = 2;

  static Future<void> onCreate(Database db, int version) async {
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

    await db.execute('''
      CREATE TABLE documents (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        fileType TEXT NOT NULL,
        sizeBytes INTEGER NOT NULL,
        expiryDate TEXT,
        storagePath TEXT,
        localPath TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        deletedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        themeMode TEXT NOT NULL DEFAULT 'system',
        defaultReminderOffsets TEXT NOT NULL DEFAULT '7,2',
        defaultReminderTime TEXT NOT NULL DEFAULT '09:00',
        remindersOn INTEGER NOT NULL DEFAULT 1,
        billingAlertsOn INTEGER NOT NULL DEFAULT 1,
        syncOn INTEGER NOT NULL DEFAULT 0,
        onboardingDone INTEGER NOT NULL DEFAULT 0,
        lastSyncAt TEXT,
        lastServerTime TEXT,
        homeTrialCardHiddenUntil TEXT
      )
    ''');

    // Default settings row
    await db.rawInsert('''
      INSERT INTO settings (id, themeMode, defaultReminderOffsets, defaultReminderTime, remindersOn, billingAlertsOn, syncOn, onboardingDone)
      VALUES (1, 'system', '7,2', '09:00', 1, 1, 0, 0)
    ''');
  }

  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      const uuid = Uuid();
      final now = DateTime.now().toUtc().toIso8601String();

      // In-place migration without losing user data
      // 1. Create temporary new tables
      await db.execute('''
        CREATE TABLE scholarships_new (
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
        CREATE TABLE requirements_new (
          id TEXT PRIMARY KEY,
          scholarshipId TEXT NOT NULL,
          title TEXT NOT NULL,
          isDone INTEGER NOT NULL DEFAULT 0,
          sortOrder INTEGER NOT NULL DEFAULT 0,
          documentId TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          deletedAt TEXT
        )
      ''');

      // 2. Fetch existing scholarships and migrate to UUID
      final oldScholarships = await db.rawQuery('SELECT * FROM scholarships');
      final Map<int, String> oldIdToNewUuid = {};

      for (final row in oldScholarships) {
        final int oldId = row['id'] as int;
        final newUuid = uuid.v4();
        oldIdToNewUuid[oldId] = newUuid;

        await db.rawInsert('''
          INSERT INTO scholarships_new (
            id, name, country, deadline, link, status, notes,
            remindersOn, reminderOffsets, reminderTime, isLocked,
            createdAt, updatedAt, deletedAt
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
          newUuid,
          row['name'],
          row['country'] ?? '',
          row['deadline'],
          row['link'],
          row['status'],
          row['notes'],
          row['remindersOn'] ?? 1,
          null, // reminderOffsets = null (uses default)
          null, // reminderTime = null (uses default)
          0,
          row['createdAt'] ?? now,
          now,
          null,
        ]);
      }

      // 3. Migrate requirements with updated scholarshipId reference
      final oldRequirements = await db.rawQuery('SELECT * FROM requirements');
      int order = 0;
      for (final row in oldRequirements) {
        final int oldScholarshipId = row['scholarshipId'] as int;
        final newScholarshipUuid = oldIdToNewUuid[oldScholarshipId];
        if (newScholarshipUuid != null) {
          final newReqUuid = uuid.v4();
          await db.rawInsert('''
            INSERT INTO requirements_new (
              id, scholarshipId, title, isDone, sortOrder, documentId,
              createdAt, updatedAt, deletedAt
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
          ''', [
            newReqUuid,
            newScholarshipUuid,
            row['title'],
            row['isDone'] ?? 0,
            order++,
            null,
            now,
            now,
            null,
          ]);
        }
      }

      // 4. Drop old tables and rename new ones
      await db.execute('DROP TABLE requirements');
      await db.execute('DROP TABLE scholarships');
      await db.execute('ALTER TABLE scholarships_new RENAME TO scholarships');
      await db.execute('ALTER TABLE requirements_new RENAME TO requirements');

      // 5. Create documents and settings tables
      await db.execute('''
        CREATE TABLE IF NOT EXISTS documents (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          fileType TEXT NOT NULL,
          sizeBytes INTEGER NOT NULL,
          expiryDate TEXT,
          storagePath TEXT,
          localPath TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          deletedAt TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS settings (
          id INTEGER PRIMARY KEY CHECK (id = 1),
          themeMode TEXT NOT NULL DEFAULT 'system',
          defaultReminderOffsets TEXT NOT NULL DEFAULT '7,2',
          defaultReminderTime TEXT NOT NULL DEFAULT '09:00',
          remindersOn INTEGER NOT NULL DEFAULT 1,
          billingAlertsOn INTEGER NOT NULL DEFAULT 1,
          syncOn INTEGER NOT NULL DEFAULT 0,
          onboardingDone INTEGER NOT NULL DEFAULT 0,
          lastSyncAt TEXT,
          lastServerTime TEXT,
          homeTrialCardHiddenUntil TEXT
        )
      ''');

      await db.rawInsert('''
        INSERT OR IGNORE INTO settings (id, themeMode, defaultReminderOffsets, defaultReminderTime, remindersOn, billingAlertsOn, syncOn, onboardingDone)
        VALUES (1, 'system', '7,2', '09:00', 1, 1, 0, 0)
      ''');
    }
  }

  static Future<void> onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }
}
