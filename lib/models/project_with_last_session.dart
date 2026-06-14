
import 'package:momentum/models/project.dart';
import 'package:momentum/models/session.dart';

class ProjectWithLastSession {
  final Project project;
  final Session? lastSession;

  const ProjectWithLastSession({
    required this.project,
    this.lastSession
  });

  factory ProjectWithLastSession.fromMap(Map<String, dynamic> map) {
    final project = Project.fromMap({
      Project.primaryKey    : map['p_id'],
      Project.colName       : map['p_name'],
      Project.colStatus     : map['p_status'],
      Project.colDescription: map['p_description']
    });

    final lastSession = map['s_id'] == null
      ? null
      : Session.fromMap({
        Session.primaryKey        : map['s_id'],
        Session.colProjectId      : map['p_id'],
        Session.colDate           : map['s_date'],
        Session.colDurationMinutes: map['s_duration_minutes'],
        Session.colNote           : map['s_note'],
      });

    return ProjectWithLastSession(project: project, lastSession: lastSession);
  }
}
