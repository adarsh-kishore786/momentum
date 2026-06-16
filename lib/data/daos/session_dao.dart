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
