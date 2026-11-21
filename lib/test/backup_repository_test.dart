// This test lives under lib/ (the project's existing test directory), so the
// analyzer treats it as library code, where dev dependencies aren't allowed.
// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/data/backup_repository.dart';
import 'package:momentum/models/idea.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/session.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Directory tempDir;
  final repository = SqfliteBackupRepository();

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('momentum_backup_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<File> createDb(String name, List<String> statements) async {
    final path = '${tempDir.path}/$name';
    final db = await openDatabase(path);
    for (final statement in statements) {
      await db.execute(statement);
    }
    await db.close();
    return File(path);
  }

  test('rejects the issue fixture: right table names, wrong columns', () async {
    final file = await createDb('wrong_columns.mbak', [
      'CREATE TABLE project (unexpected_column TEXT)',
      'CREATE TABLE session (unexpected_column TEXT)',
      'CREATE TABLE idea (unexpected_column TEXT)',
      "INSERT INTO project VALUES ('Synthetic project fixture')",
      "INSERT INTO session VALUES ('Synthetic session fixture')",
      "INSERT INTO idea VALUES ('Synthetic idea fixture')",
    ]);

    expect(await repository.isValidMomentumDb(file), isFalse);
  });

  test('rejects a table that is missing one required column', () async {
    final file = await createDb('missing_column.mbak', [
      'CREATE TABLE project (id INTEGER PRIMARY KEY, name TEXT, status TEXT)',
      Session.createTableSql,
      Idea.createTableSql,
    ]);

    expect(await repository.isValidMomentumDb(file), isFalse);
  });

  test('rejects right column names with wrong value types', () async {
    final file = await createDb('wrong_types.mbak', [
      'CREATE TABLE project (id TEXT PRIMARY KEY, name INTEGER, '
          'description BLOB, status REAL)',
      'CREATE TABLE session (id TEXT PRIMARY KEY, project_id TEXT, date TEXT, '
          'duration_minutes TEXT, note INTEGER)',
      'CREATE TABLE idea (id TEXT PRIMARY KEY, project_id TEXT, '
          'description INTEGER, state INTEGER)',
      "INSERT INTO project VALUES ('not-an-int', 12345, x'00FF', 7.5)",
      "INSERT INTO session VALUES ('s-1', 'p-1', '2026-11-15', 'twenty', 99)",
      "INSERT INTO idea VALUES ('i-1', 'p-1', 12345, 1)",
    ]);

    expect(await repository.isValidMomentumDb(file), isFalse);
  });

  test('rejects an invalid enum value in an otherwise valid schema', () async {
    final file = await createDb('bad_enum.mbak', [
      'CREATE TABLE project (id INTEGER PRIMARY KEY, name TEXT, '
          'description TEXT, status TEXT)',
      Session.createTableSql,
      Idea.createTableSql,
      "INSERT INTO project (name, description, status) "
          "VALUES ('X', 'Y', 'banana')",
    ]);

    expect(await repository.isValidMomentumDb(file), isFalse);
  });

  test('rejects NULL in a required column', () async {
    final file = await createDb('null_column.mbak', [
      'CREATE TABLE project (id INTEGER PRIMARY KEY, name TEXT, '
          'description TEXT, status TEXT)',
      Session.createTableSql,
      Idea.createTableSql,
      "INSERT INTO project (name, description, status) "
          "VALUES (NULL, 'Y', 'planned')",
    ]);

    expect(await repository.isValidMomentumDb(file), isFalse);
  });

  test('accepts the current schema', () async {
    final file = await createDb('valid.mbak', [
      Project.createTableSql,
      Session.createTableSql,
      Idea.createTableSql,
    ]);

    expect(await repository.isValidMomentumDb(file), isTrue);
  });

  test('accepts the current schema with extra columns', () async {
    final file = await createDb('extra_columns.mbak', [
      Project.createTableSql,
      Session.createTableSql,
      Idea.createTableSql,
      'ALTER TABLE project ADD COLUMN future_column TEXT',
      'ALTER TABLE session ADD COLUMN future_column INTEGER',
      'ALTER TABLE idea ADD COLUMN future_column TEXT',
    ]);

    expect(await repository.isValidMomentumDb(file), isTrue);
  });

  test('rejects a file that is not a database', () async {
    final file = File('${tempDir.path}/not_a_db.mbak');
    await file.writeAsString('definitely not sqlite');

    expect(await repository.isValidMomentumDb(file), isFalse);
  });
}
