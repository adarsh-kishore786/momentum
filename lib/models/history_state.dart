import 'package:momentum/models/session_with_project.dart';

class HistoryState {
  final List<SessionWithProjectName> sessions;
  final bool hasMore;

  const HistoryState({
    required this.sessions,
    required this.hasMore
  });
}
