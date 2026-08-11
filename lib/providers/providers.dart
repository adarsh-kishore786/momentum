import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/data/daos/idea_dao.dart';
import 'package:momentum/data/daos/session_dao.dart';
import 'package:momentum/data/database_helper.dart';
import 'package:momentum/data/daos/project_dao.dart';
import 'package:momentum/data/repository.dart';
import 'package:sqflite/sqflite.dart';

final databaseProvider = FutureProvider<Database>((ref) {
  return DatabaseHelper.instance.database;
});

// Dao Providers
final projectDaoProvider = FutureProvider<ProjectDao>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return ProjectDao(db: db);
});

final sessionDaoProvider = FutureProvider<SessionDao>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return SessionDao(db: db);
});

final ideaDaoProvider = FutureProvider<IdeaDao>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return IdeaDao(db: db);
});

// Repository Provider
final repositoryProvider = FutureProvider<Repository>((ref) async {
  return SqfliteRepository(
    projectDao: await ref.watch(projectDaoProvider.future),
    sessionDao: await ref.watch(sessionDaoProvider.future),
    ideaDao:    await ref.watch(ideaDaoProvider.future)
  );
});
