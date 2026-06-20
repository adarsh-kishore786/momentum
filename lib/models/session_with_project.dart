import 'package:momentum/models/session.dart';

class SessionWithProjectName {
  final Session session;
  final String projectName;

  const SessionWithProjectName({
    required this.session,
    required this.projectName
  });

  factory SessionWithProjectName.fromMap(Map<String, dynamic> map) {
    final session = Session.fromMap(map);
    final projectName = map['project_name'] as String;

    return SessionWithProjectName(session: session, projectName: projectName);
  }
}
