import 'package:momentum/data/database_exception.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/session.dart';
import 'package:momentum/models/session_cursor.dart';
import 'package:momentum/models/session_with_project.dart';
import 'package:sqflite/sqflite.dart';

class SessionDao {
  final Database db;

  SessionDao({required this.db});

  Future<Session> insert(Session session) async {
    try {
      final id = await db.insert(
        Session.table,
        session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort
      );

      return session.copyWith(id: id);

    } on DatabaseException catch (e, stack) {
      Error.throwWithStackTrace(
        MomentumDBException('Failed to insert session', cause: e),
        stack
      );
    }
  }

  Future<void> delete(Session session) async {
    try {
      await db.delete(
        Session.table,
        where: '${Session.primaryKey} = ?',
        whereArgs: [session.id]
      );
    } on DatabaseException catch (e, stack) {
      Error.throwWithStackTrace(
        MomentumDBException('Failed to delete session', cause: e),
        stack
      );
    }
  }

  Future<List<SessionWithProjectName>> getAll({
      SessionCursor? after,
      int limit = 30
  }) async {
    if (limit <= 0) {
      throw ArgumentError('limit must be positive');
    }

    if (after != null && after.id <= 0) {
      throw ArgumentError('cursor id must be a valid number');
    }

    String sql = '''
      SELECT
        s.${Session.primaryKey} as ${Session.primaryKey},
        s.${Session.colProjectId} as ${Session.colProjectId},
        s.${Session.colDate} as ${Session.colDate},
        s.${Session.colNote} as ${Session.colNote},
        s.${Session.colDurationMinutes} as ${Session.colDurationMinutes},
        p.${Project.colName} as project_name
      FROM
        ${Session.table} s JOIN ${Project.table} p
        ON s.${Session.colProjectId} = p.${Project.primaryKey}
    ''';

    if (after != null) {
      sql = '''
        $sql
        WHERE
          (${Session.colDate} < ${after.date.millisecondsSinceEpoch} OR
            (${Session.colDate} = ${after.date.millisecondsSinceEpoch} AND
              ${Session.primaryKey} < ${after.id})
          )
      ''';
    }

    try {
      final rows = await db.rawQuery(sql);
      return rows.map(SessionWithProjectName.fromMap).toList();
    } on DatabaseException catch (e, stack) {
      Error.throwWithStackTrace(
       MomentumDBException('Could not fetch sessions', cause: e), 
       stack
      );
    }
  }
}
