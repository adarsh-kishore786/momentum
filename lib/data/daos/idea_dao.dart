import 'package:momentum/data/database_exception.dart';
import 'package:momentum/models/idea.dart';
import 'package:momentum/models/idea_state.dart';
import 'package:sqflite/sqflite.dart';

class IdeaDao {
  final Database db;

  IdeaDao({required this.db});

  Future<int> insert(Idea idea) async {
    try {
      final id = await db.insert(
        Idea.table,
        idea.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort
      );

      return id;
    } on DatabaseException catch (e, stack) {
      Error.throwWithStackTrace(
        MomentumDBException('Failed to insert idea', cause: e), 
        stack
      );
    }
  }

  Future<void> update(Idea idea) async {
    if (idea.id == null) {
      throw ArgumentError('Cannot update an idea without an ID');
    }

    try {
      final count = await db.update(
        Idea.table, 
        idea.toMap(),
        where: '${Idea.primaryKey} = ?',
        whereArgs: [idea.id]
      );

      if (count == 0) {
        throw MomentumDBException('Idea not found: ${idea.id}');
      }
    } on DatabaseException catch (e, stack) {
      Error.throwWithStackTrace(
        MomentumDBException('Failed to update idea', cause: e),
        stack
      );
    }
  }

  Future<void> delete(int id) async {
    try {
      await db.delete(
        Idea.table,
        where: '${Idea.primaryKey} = ?',
        whereArgs: [id]
      );
    } on DatabaseException catch (e, stack) {
      Error.throwWithStackTrace(
        MomentumDBException('Failed to delete idea', cause: e),
        stack
      );
    }
  }

  Future<List<Idea>> getIdeas(int projectId) async {
    try {
      final rows = await db.query(
        Idea.table,
        where: '${Idea.colProjectId} = ?',
        whereArgs: [projectId],
        orderBy: '${Idea.colDescription} ASC'
      );

      return rows.map(Idea.fromMap).toList();

    } on DatabaseException catch(e, stack) {
      Error.throwWithStackTrace(
        MomentumDBException('Failed to fetch ideas', cause: e),
        stack
      );
    }
  }

  Future<bool> isIdeaDone(int ideaId) async {
    try {
      final rows = await db.query(
        Idea.table,
        where: 
          '${Idea.primaryKey} = ? AND ${Idea.colState} = ${IdeaState.done}',
        whereArgs: [ideaId],
        limit: 1
      );

      return rows.isNotEmpty;

    } on DatabaseException catch(e, stack) {
      Error.throwWithStackTrace(
        MomentumDBException('Failed to fetch idea', cause: e),
        stack
      );
    }
  }
}
