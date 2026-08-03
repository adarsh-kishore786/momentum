import 'dart:io';

import 'package:momentum/data/backup_exception.dart';
import 'package:momentum/data/database_helper.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

abstract interface class BackupRepository {
  /// Returns the path to a consistent copy of the DB ready to share/save.
  Future<File> prepareExport();

  /// Validates [sourcePath], replaces the live DB, reopens it.
  /// Throws [InvalidBackupFileException] if the file isn't a valid Momentum DB.
  Future<void> importFrom(String sourcePath);
}

class SqfliteBackupRepository implements BackupRepository {
  static const _expectedTables = {'project', 'session', 'idea'};

  @override
  Future<File> prepareExport() async {
    try {
      // 1. Get the open Database handle directly without closing it
      final db = await DatabaseHelper.instance.database;

      // 2. Prepare target export location
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final exportPath = join(tempDir.path, 'momentum_backup_$timestamp.mbak');

      // 3. Ensure the destination file doesn't already exist
      final exportFile = File(exportPath);
      if (await exportFile.exists()) {
        await exportFile.delete();
      }

      // 4. Safely escape single quotes in path string
      final escapedPath = exportPath.replaceAll("'", "''");

      // 5. Run online backup directly from SQLite engine
      await db.rawQuery("VACUUM INTO '$escapedPath'");

      return exportFile;
    } on DatabaseException catch (e) {
      throw BackupIOException('Failed to export database: ${e.toString()}');
    } on FileSystemException catch (e) {
      throw BackupIOException('Could not handle backup file: ${e.message}');
    }
  }

  @override
  Future<void> importFrom(String sourcePath) async {
    final candidate = File(sourcePath);
    if (!await candidate.exists()) {
      throw const InvalidBackupFileException();
    }

    if (!await _isValidMomentumDb(candidate)) {
      throw const InvalidBackupFileException();
    }

    final dbPath = await DatabaseHelper.instance.databasePath;
    final currentDb = File(dbPath);

    // safety net: keep the current DB in case something goes wrong
    final rollback = File('$dbPath.rollback');

    try {
      // Import STILL requires closing connection to overwrite disk files
      await DatabaseHelper.instance.closeForFileOp();

      if (await currentDb.exists()) {
        await currentDb.copy(rollback.path);
      }

      await candidate.copy(dbPath);
    } catch (e) {
      if (await rollback.exists()) {
        await rollback.copy(dbPath);
      }
      rethrow;
    } finally {
      if (await rollback.exists()) {
        await rollback.delete();
      }
      await DatabaseHelper.instance.database; // reopen
    }
  }

  Future<bool> _isValidMomentumDb(File file) async {
    try {
      final db = await openDatabase(file.path, readOnly: true);
      final tables = await db.query(
        'sqlite_master',
        columns: ['name'],
        where: 'type = ?',
        whereArgs: ['table'],
      );
      await db.close();
      final names = tables.map((r) => r['name'] as String).toSet();
      return _expectedTables.every(names.contains);
    } catch (_) {
      return false; // not a sqlite file, or unreadable
    }
  }
}
