import 'package:momentum/data/daos/project_dao.dart';
import 'package:momentum/data/daos/session_dao.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/project_with_last_session.dart';
import 'package:momentum/models/session.dart';

abstract interface class Repository {
  Future<Project> insertProject(Project project);
  Future<void> updateProject(Project project);
  Future<List<ProjectWithLastSession>> getProjectsWithLastSession();

  Future<Session> insertSession(Session session);
  Future<void> deleteSession(Session session);
  Future<List<Session>> getAll({SessionCursor? after, int? limit});
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
  Future<Project> insertProject(Project project) =>
    _projectDao.insert(project);
 

  @override
  Future<void> updateProject(Project project) =>
    _projectDao.update(project);

  @override
  Future<List<ProjectWithLastSession>> getProjectsWithLastSession() =>
    _projectDao.getProjectsWithLastSession();

  @override
  Future<Session> insertSession(Session session) =>
    _sessionDao.insert(session);

  @override
  Future<void> deleteSession(Session session) =>
    _sessionDao.delete(session);

  @override
  Future<List<Session>> getAll({SessionCursor? after, int? limit}) {
    if (limit != null) {
      return _sessionDao.getAll(after: after, limit: limit);
    }
    return _sessionDao.getAll(after: after);
  }
}
