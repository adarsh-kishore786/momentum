import 'package:momentum/data/repository.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/project_with_last_session.dart';
import 'package:momentum/models/session.dart';
import 'package:momentum/models/session_cursor.dart';
import 'package:momentum/models/session_with_project.dart';

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
  Future<List<SessionWithProjectName>> getAllSessions({SessionCursor? after, int? limit}) async {
    final arrayMap = [
      {
        'id': 1,
        'project_id': 1,
        'date': DateTime(2026, 05, 04).millisecondsSinceEpoch,
        'duration_minutes': 50,
        'note': "Worked on network stack",
        'project_name': "Beej's Computer Networking"
      }
    ];

    return arrayMap.map(SessionWithProjectName.fromMap).toList();
  }
}
