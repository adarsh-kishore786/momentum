class Session {
  final int? id;
  final int projectId;
  final DateTime date;
  final int durationMinutes;
  final String note;

  static const String table = "session";
  static const String primaryKey = "id";

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
      id: map['id'] as int?,
      projectId: map['projectId'] as int,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int, isUtc: true),
      durationMinutes: map['durationMinutes'] as int,
      note: map['note'] as String
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'projectId': projectId,
      'date': date.millisecondsSinceEpoch,
      'durationMinutes': durationMinutes,
      'note': note,
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
