import 'package:momentum/data/daos/project_dao.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/project_with_last_session.dart';

abstract interface class ProjectRepository {
  Future<Project> insert(Project project);
  Future<void> update(Project project);
  Future<List<ProjectWithLastSession>> getProjectsWithLastSession();
}

class SqfliteProjectRepository implements ProjectRepository {
  final ProjectDao _dao;

  SqfliteProjectRepository(this._dao);

  @override
  Future<Project> insert(Project project) =>
    _dao.insert(project);
 

  @override
  Future<void> update(Project project) =>
    _dao.update(project);

  @override
  Future<List<ProjectWithLastSession>> getProjectsWithLastSession() =>
    _dao.getProjectsWithLastSession();
}
