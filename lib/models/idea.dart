import 'package:momentum/models/idea_state.dart';
import 'package:momentum/models/project.dart';

class Idea {
  static const String table = "idea";
  static const String primaryKey = "id";
  static const String colProjectId = "project_id";
  static const String colDescription = "description";
  static const String colState = "state";

  static const String createTableSql = '''
      CREATE TABLE $table (
        $primaryKey      INTEGER      PRIMARY KEY AUTOINCREMENT,
        $colProjectId    INTEGER      NOT NULL,
        $colDescription  TEXT         NOT NULL,
        $colState        TEXT         NOT NULL 
          CHECK ($colState IN ('open', 'done')),

        FOREIGN KEY ($colProjectId) REFERENCES 
        ${Project.table}(${Project.primaryKey})
        ON DELETE CASCADE
      )
    ''';

  final int? id;
  final int projectId;
  final String description;
  final IdeaState state;

  Idea({
    this.id,
    required this.projectId,
    required this.description,
    this.state = IdeaState.open
  }) : assert(description.isNotEmpty, 'Idea description cannot be empty'),
       assert(projectId > 0, 'project Id must be a valid ID');

  factory Idea.fromMap(Map<String, dynamic> map) {
    return Idea(
      id: map[primaryKey] as int?,
      projectId: map[colProjectId] as int,
      description: map[colDescription] as String,
      state: IdeaState.values.byName(map[colState] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) primaryKey: id,
      colProjectId: projectId,
      colDescription: description,
      colState: state.name,
    };
  }

  Idea copyWith({int? id, int? projectId, String? description, IdeaState? state}) {
    return Idea(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      description: description ?? this.description,
      state: state ?? this.state
    );
  } 
}
