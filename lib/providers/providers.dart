import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/data/daos/session_dao.dart';
import 'package:momentum/data/database_helper.dart';
import 'package:momentum/data/daos/project_dao.dart';
import 'package:momentum/data/repository.dart';
import 'package:sqflite/sqflite.dart';

final databaseProvider = FutureProvider<Database>((ref) {
  return DatabaseHelper.instance.database;
});

// Dao Providers
final projectDaoProvider = Provider<ProjectDao>((ref) {
  final db = ref.watch(databaseProvider).requireValue;
  return ProjectDao(db: db);
});

final sessionDaoProvider = Provider<SessionDao>((ref) {
  final db = ref.watch(databaseProvider).requireValue;
  return SessionDao(db: db);
});

// Repository Provider
final repositoryProvider = Provider<Repository>((ref) {
  return SqfliteRepository(
    projectDao: ref.watch(projectDaoProvider),
    sessionDao: ref.watch(sessionDaoProvider)
  );
});
