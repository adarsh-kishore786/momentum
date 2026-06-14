import 'package:momentum/data/database_exception.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/project_status.dart';
import 'package:momentum/models/project_with_last_session.dart';
import 'package:momentum/models/session.dart';
import 'package:sqflite/sqflite.dart';

class ProjectDao {
  final Database db;

  ProjectDao({required this.db});

  Future<Project> insert(Project project) async {
    try {
      final id = await db.insert(
        Project.table,
        project.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort
      );

      return project.copyWith(id: id);

    } on DatabaseException catch (e, stack) {
      Error.throwWithStackTrace(
        MomentumDBException('Failed to insert project', cause: e),
        stack
      );
    }
  }

  Future<void> update(Project project) async {
    if (project.id == null) {
      throw ArgumentError('Cannot update a project without an ID');
    }
    try {
      final count = await db.update(
        Project.table,
        project.toMap(),
        where: '${Project.primaryKey} = ?',
        whereArgs: [project.id]
      );

      if (count == 0) {
        throw MomentumDBException('Project not found: ${project.id}');
      }

    } on DatabaseException catch (e, stack) {
      Error.throwWithStackTrace(
        MomentumDBException('Failed to update project', cause: e),
        stack
      );
    }
  }

  Future<void> delete(int id) async {
    try {
      await db.delete(
        Project.table,
        where: '${Project.primaryKey} = ?',
        whereArgs: [id]
      );
    } on DatabaseException catch (e, stack) {
      Error.throwWithStackTrace(
        MomentumDBException('Failed to delete project', cause: e),
        stack
      );
    }
  }

  Future<Project> getById(int id) async {
    try {
      final rows = await db.query(
                          Project.table,
                          where: '${Project.primaryKey} = ?',
                          whereArgs: [id]
                         );
      
      if (rows.isEmpty) {
        throw MomentumDBException('Project not found: $id');
      }

      return Project.fromMap(rows.first);

    } on MomentumDBException {
      rethrow;
    } on DatabaseException catch (e, stack) {
      Error.throwWithStackTrace(
        MomentumDBException('Failed to get project', cause: e),
        stack);
    }
  }

  Future<List<Project>> getAll({ProjectStatus? status}) async {
    try {
      final rows = await db.query(
        Project.table,
        where: status != null ? 'status = ?' : null,
        whereArgs: status != null ? [status] : null,
        orderBy: 'name ASC'
      );

      return rows.map(Project.fromMap).toList();

    } on DatabaseException catch(e, stack) {
      Error.throwWithStackTrace(
        MomentumDBException('Failed to fetch projects', cause: e),
        stack
      );
    }
  }

  Future<List<ProjectWithLastSession>> getProjectsWithLastSession() async {
    const sql = '''
      SELECT
        p.${Project.primaryKey}         as p_id,
        p.${Project.colName}            as p_name,
        p.${Project.colStatus}          as p_status,
        p.${Project.colDescription}     as p_description,
        s.${Session.primaryKey}         as s_id,
        s.${Session.colDate}            as s_date,
        s.${Session.colDurationMinutes} as s_duration_minutes,
        s.${Session.colNote}            as s_note
      FROM ${Project.table} p
      LEFT JOIN ${Session.table} s
        -- this first condition is redundant but helps in indexing
        ON s.${Session.colProjectId} = p.${Project.primaryKey}
        AND s.${Session.primaryKey} = (
          SELECT ${Session.primaryKey}
          FROM ${Session.table}
          WHERE ${Session.colProjectId} = p.${Project.primaryKey}
          ORDER BY ${Session.colDate} DESC
          LIMIT 1
        )
      WHERE p.${Project.colStatus} != ?
      ORDER BY 
        CASE WHEN s.${Session.colDate} IS NULL THEN 1 ELSE 0 END,
        s.${Session.colDate} DESC
    ''';

    try {

      final rows = await db.rawQuery(sql, [ProjectStatus.archived.name]);
      return rows.map(ProjectWithLastSession.fromMap).toList();

    } on DatabaseException catch (e, stack) {
      Error.throwWithStackTrace(
        MomentumDBException('Could not fetch projects with last session', cause: e),
        stack
      );
    }
  }
}
