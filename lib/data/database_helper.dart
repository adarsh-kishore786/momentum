import 'dart:io';

import 'package:momentum/data/backup_exception.dart';
import 'package:momentum/data/database_exception.dart';
import 'package:momentum/models/idea.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/session.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static const int _version = 1;
  static Database? _db;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    try {
      var databasePath = await getDatabasesPath();
      String name = "momentum.db";
      String path = join(databasePath, name);

      return await openDatabase(
        path,
        version: _version,
        onCreate: _createDB,
        onOpen: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
        onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
      );
    } catch (e, stack) {
      Error.throwWithStackTrace(
        MomentumDBException('Failed to initialise database: $e'),
        stack
      );
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(Project.createTableSql);
    await db.execute(Session.createTableSql);
    await db.execute(Idea.createTableSql);
  }

  Future<String> get databasePath async =>
      join(await getDatabasesPath(), 'momentum.db');

  /// Flushes WAL into the main file and closes the connection.
  /// Must be called before any raw file copy of the DB.
  Future<void> closeForFileOp() async {
    if (_db == null) return;
    final result = await _db!.rawQuery('PRAGMA wal_checkpoint(TRUNCATE)');
    final busy = result.first['busy'] as int? ?? 0;
    if (busy != 0) {
      throw const BackupIOException(
        'Could not flush database — try again after closing other operations.',
      );
    }
    await _db!.close();
    _db = null;
  }

  Future<void> exportDatabase(Database db, String targetDirectoryPath) async {
    // 1. Generate a target file path
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupPath = '$targetDirectoryPath/backup_$timestamp.db';

    // 2. Ensure target file does NOT exist (VACUUM INTO fails if file exists)
    final backupFile = File(backupPath);
    if (await backupFile.exists()) {
      await backupFile.delete();
    }

    // 3. Escape single quotes to prevent SQL injection or path errors
    final escapedPath = backupPath.replaceAll("'", "''");

    try {
      // 4. Run the vacuum export
      await db.rawQuery("VACUUM INTO '$escapedPath'");
    } catch (e) {
      throw BackupIOException('Failed to export database: $e');
    }
  }
}
