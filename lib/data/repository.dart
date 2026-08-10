import 'package:momentum/data/daos/project_dao.dart';
import 'package:momentum/data/daos/session_dao.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/project_with_last_session.dart';
import 'package:momentum/models/session.dart';
import 'package:momentum/models/session_cursor.dart';
import 'package:momentum/models/session_with_project.dart';

abstract interface class Repository {
  Future<int> insertProject(Project project);
  Future<void> updateProject(Project project);
  Future<void> deleteProject(int projectId);
  Future<Project> getProjectById(int projectId);
  Future<List<ProjectWithLastSession>> getProjectsWithLastSession();
  Future<bool> isProjectActive(int projectId);

  Future<Session> insertSession(Session session);
  Future<void> deleteSession(int sessionId);
  Future<void> updateSession(Session session);
  Future<List<Session>> getProjectSessions(int projectId, int offset);
  Future<List<SessionWithProjectName>> getAllSessions({SessionCursor? after, int? limit});
}

class SqfliteRepository implements Repository {
  final ProjectDao _projectDao;
  final SessionDao _sessionDao;

  SqfliteRepository({
    required ProjectDao projectDao,
    required SessionDao sessionDao
  }) : _projectDao = projectDao,
       _sessionDao = sessionDao;

  @override
  Future<int> insertProject(Project project) =>
    _projectDao.insert(project);
 
  @override
  Future<void> updateProject(Project project) =>
    _projectDao.update(project);

  @override
  Future<void> deleteProject(int projectId) =>
    _projectDao.delete(projectId);

  @override
  Future<Project> getProjectById(int projectId) =>
    _projectDao.getById(projectId);

  @override
  Future<List<ProjectWithLastSession>> getProjectsWithLastSession() =>
    _projectDao.getProjectsWithLastSession();

  @override
  Future<bool> isProjectActive(int projectId) =>
    _projectDao.isProjectActive(projectId);

  @override
  Future<Session> insertSession(Session session) =>
    _sessionDao.insert(session);

  @override
  Future<void> deleteSession(int sessionId) =>
    _sessionDao.delete(sessionId);

  @override
  Future<void> updateSession(Session session) =>
    _sessionDao.update(session);

  @override
  Future<List<SessionWithProjectName>> getAllSessions({SessionCursor? after, int? limit}) {
    if (limit != null) {
      return _sessionDao.getAll(after: after, limit: limit);
    }
    return _sessionDao.getAll(after: after);
  }

  @override
  Future<List<Session>> getProjectSessions(int projectId, int offset) =>
    _sessionDao.getProjectSessions(projectId, offset);
}
