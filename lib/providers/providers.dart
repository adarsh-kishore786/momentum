import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/data/database_helper.dart';
import 'package:momentum/data/daos/project_dao.dart';
import 'package:momentum/data/repository/project_repository.dart';
import 'package:sqflite/sqflite.dart';

final databaseProvider = FutureProvider<Database>((ref) {
  return DatabaseHelper.instance.database;
});

final projectDaoProvider = Provider<ProjectDao>((ref) {
  final db = ref.watch(databaseProvider).requireValue;
  return ProjectDao(db: db);
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final dao = ref.watch(projectDaoProvider);
  return SqfliteProjectRepository(dao);
});
