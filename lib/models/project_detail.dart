import 'package:momentum/models/project.dart';
import 'package:momentum/models/session.dart';

class ProjectDetail {
  final Project project;
  final List<Session> sessions;

  const ProjectDetail({
    required this.project,
    required this.sessions
  });
}
