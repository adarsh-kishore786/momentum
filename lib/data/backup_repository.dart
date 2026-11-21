import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:momentum/data/backup_exception.dart';
import 'package:momentum/data/database_helper.dart';
import 'package:momentum/models/idea.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/session.dart';
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
  /// The columns this version of the app reads from each table. A backup must
  /// contain at least these; extra columns are allowed so backups from future
  /// versions with an extended schema remain importable.
  static const _requiredColumns = <String, Set<String>>{
    Project.table: {
      Project.primaryKey,
      Project.colName,
      Project.colDescription,
      Project.colStatus,
    },
    Session.table: {
      Session.primaryKey,
      Session.colProjectId,
      Session.colDate,
      Session.colDurationMinutes,
      Session.colNote,
    },
    Idea.table: {
      Idea.primaryKey,
      Idea.colProjectId,
      Idea.colDescription,
      Idea.colState,
    },
  };

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

    if (!await isValidMomentumDb(candidate)) {
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

  /// Checks the candidate's schema, not just its table names. Matching names
  /// alone would let a file with incompatible columns replace the live DB and
  /// leave every query against it failing with "no such column".
  @visibleForTesting
  Future<bool> isValidMomentumDb(File file) async {
    Database? db;
    try {
      db = await openDatabase(file.path, readOnly: true);
      for (final entry in _requiredColumns.entries) {
        final rows = await db.rawQuery(
          'SELECT name FROM pragma_table_info(?)',
          [entry.key],
        );
        final columns = rows.map((r) => r['name'] as String).toSet();
        if (!entry.value.every(columns.contains)) {
          return false;
        }
      }
      return true;
    } catch (_) {
      return false; // not a sqlite file, or unreadable
    } finally {
      await db?.close();
    }
  }
}
