import 'package:momentum/data/database_exception.dart';
import 'package:momentum/models/session.dart';
import 'package:sqflite/sqflite.dart';

class SessionCursor {
  final DateTime date;
  final int id;

  const SessionCursor({
    required this.date,
    required this.id
  });
}

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

  Future<List<Session>> getAll({
      SessionCursor? after,
      int limit = 30
  }) async {
    if (limit <= 0) {
      throw ArgumentError('limit must be positive');
    }

    if (after != null && after.id <= 0) {
      throw ArgumentError('cursor id must be a valid number');
    }

    try {
      final rows = await db.query(
        Session.table,
        where: after != null
            ? '''(${Session.colDate} < ? OR (${Session.colDate} = ?
              AND ${Session.primaryKey} < ?))''' 
            : null,
        whereArgs: after != null
            ? [
                after.date.millisecondsSinceEpoch, 
                after.date.millisecondsSinceEpoch,
                after.id
              ] 
            : null,
        orderBy: '${Session.colDate} DESC, ${Session.primaryKey} DESC',
        limit: limit
      );
      return rows.map(Session.fromMap).toList();
    } on DatabaseException catch (e, stack) {
      Error.throwWithStackTrace(
       MomentumDBException('Could not fetch sessions', cause: e), 
       stack
      );
    }
  }
}
