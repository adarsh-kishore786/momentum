import 'package:momentum/data/repository/project_repository.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/project_with_last_session.dart';

class FakeProjectRepository implements ProjectRepository {
  @override
  Future<List<ProjectWithLastSession>> getProjectsWithLastSession() async {
    final now = DateTime.now().toUtc();

    return [
      ProjectWithLastSession.fromMap({
        'p_id': 1, 'p_name': 'Compiler in Rust',
        'p_status': 'active',
        'p_description': 'Building a toy language compiler — lexer, parser, codegen.',
        's_id': 1,
        's_date': now.subtract(const Duration(days: 0)).millisecondsSinceEpoch,
        's_duration_minutes': 150,
        's_note': 'Finished lexer pass, started parser skeleton.',
      }),
      ProjectWithLastSession.fromMap({
        'p_id': 2, 'p_name': 'Ray Tracer',
        'p_status': 'active',
        'p_description': 'Ray tracer in C++.',
        's_id': 2,
        's_date': now.subtract(const Duration(days: 5)).millisecondsSinceEpoch,
        's_duration_minutes': 80,
        's_note': 'Added reflection + refraction, scene renders cleanly.',
      }),
      ProjectWithLastSession.fromMap({
        'p_id': 3, 'p_name': 'Flutter Expense App',
        'p_status': 'active',
        'p_description': 'Personal expense tracker in Flutter.',
        's_id': 3,
        's_date': now.subtract(const Duration(days: 18)).millisecondsSinceEpoch,
        's_duration_minutes': 120,
        's_note': 'Wired up SQLite, basic CRUD works.',
      }),
      ProjectWithLastSession.fromMap({
        'p_id': 4, 'p_name': 'CHIP-8 Emulator',
        'p_status': 'dormant',
        'p_description': 'CHIP-8 emulator in Rust.',
        's_id': 4,
        's_date': now.subtract(const Duration(days: 47)).millisecondsSinceEpoch,
        's_duration_minutes': 60,
        's_note': 'Got basic opcodes running.',
      }),
      ProjectWithLastSession.fromMap({
        'p_id': 5, 'p_name': 'ML From Scratch',
        'p_status': 'dormant',
        'p_description': 'Implementing ML algorithms from scratch in Python.',
        's_id': 5,
        's_date': now.subtract(const Duration(days: 61)).millisecondsSinceEpoch,
        's_duration_minutes': 90,
        's_note': 'Implemented backprop, loss converging.',
      }),
    ];
  }

  @override
  Future<Project> insert(Project project) async => project;

  @override
  Future<void> update(Project project) async {}
}
