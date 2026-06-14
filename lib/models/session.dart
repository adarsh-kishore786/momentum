import 'package:momentum/models/project.dart';

class Session {
  static const String table = "session";
  static const String primaryKey = "id";
  static const String colProjectId = "project_id";
  static const String colDate = "date";
  static const String colDurationMinutes = "duration_minutes";
  static const String colNote = "note";
  
  static const String createTableSql = '''
      CREATE TABLE $table (
        $primaryKey          INTEGER      PRIMARY KEY AUTOINCREMENT,
        $colProjectId        INTEGER      NOT NULL,
        $colDate             INTEGER      NOT NULL,
        $colDurationMinutes  INTEGER      NOT NULL,
        $colNote             TEXT         NOT NULL,
        FOREIGN KEY ($colProjectId) REFERENCES 
          ${Project.table}(${Project.primaryKey})
          ON DELETE CASCADE
      )
    ''';

  final int? id;
  final int projectId;
  final DateTime date;
  final int durationMinutes;
  final String note;

  Session({
    this.id,
    required this.projectId,
    required this.date,
    required this.durationMinutes,
    required this.note
  }) : assert(durationMinutes > 0, 'Duration must be positive'),
       assert(note.isNotEmpty, 'Note cannot be empty'),
       assert(projectId > 0, 'Project Id must be valid'),
       assert(date.isUtc, 'Date must be in UTC format');

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map[primaryKey] as int?,
      projectId: map[colProjectId] as int,
      date: DateTime.fromMillisecondsSinceEpoch(map[colDate] as int, isUtc: true),
      durationMinutes: map[colDurationMinutes] as int,
      note: map[colNote] as String
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) primaryKey: id,
      colProjectId: projectId,
      colDate: date.millisecondsSinceEpoch,
      colDurationMinutes: durationMinutes,
      colNote: note,
    };
  }

  Session copyWith({int? id, int? projectId, DateTime? date, int? durationMinutes,
        String? note}) {
    return Session(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        date: date ?? this.date,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        note: note ?? this.note
    );
  }
}
