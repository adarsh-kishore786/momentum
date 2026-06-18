import 'package:momentum/data/daos/session_dao.dart';
import 'package:momentum/data/repository.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/project_with_last_session.dart';
import 'package:momentum/models/session.dart';

class FakeRepository implements Repository {
  FakeRepository();

  @override
  Future<Project> insertProject(Project project) async =>
    throw UnimplementedError("Project insertion");

  @override
  Future<Project> updateProject(Project project) async =>
    throw UnimplementedError("Project updation");

  @override
  Future<List<ProjectWithLastSession>> getProjectsWithLastSession() async {
    final List<Map<String, dynamic>> projectsWithLastSession = [
      {
        'p_id': 1,
        'p_name': "Connecting the dots",
        'p_status': "active",
        'p_description': "Understanding the architecture of modern AI",
        's_id': 1,
        's_date': DateTime(2026, 6, 18).millisecondsSinceEpoch,
        's_duration_minutes': 50,
        's_note': "Read on different types of parameterised autoregressive models"
      },
      {
        'p_id': 4,
        'p_name': "Computer Systems",
        'p_status': "active",
        'p_description': "Understanding computer systems better",
        's_id': 2,
        's_date': DateTime(2026, 5, 31).millisecondsSinceEpoch,
        's_duration_minutes': 85,
        's_note': "Solved some problems of CS:APP Ch 2"
      },
      {
        'p_id': 5,
        'p_name': "Computer Networking",
        'p_status': "archived",
        'p_description': "Understanding computer networking",
        's_id': 4,
        's_date': DateTime(2026, 2, 27).millisecondsSinceEpoch,
        's_duration_minutes': 30,
        's_note': "Read Beej's guide to networking on `accept()`"
      },
      {
        'p_id': 2,
        'p_name': "Crafting Interpreters",
        'p_status': "archived",
        'p_description': "Understanding and building compilers and interpreters"
      },
      {
        'p_id': 3,
        'p_name': "BYOLLM",
        'p_status': "planned",
        'p_description': "Building LLM from scratch in Rust"
      }
    ];

    return projectsWithLastSession.map(ProjectWithLastSession.fromMap).toList();
  }

  @override
  Future<Session> insertSession(Session session) async =>
    throw UnimplementedError("Session insertion");

  @override
  Future<void> deleteSession(Session session) =>
    throw UnimplementedError("Session deletion");

  @override
  Future<List<Session>> getAllSessions({SessionCursor? after, int? limit}) =>
    throw UnimplementedError("Fetching sessions");
}
