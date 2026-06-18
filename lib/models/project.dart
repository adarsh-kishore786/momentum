import 'package:momentum/models/project_status.dart';

class Project {
  static const String table = "project";
  static const String primaryKey = "id";
  static const String colName = "name";
  static const String colDescription = "description";
  static const String colStatus = "status";

  static const String createTableSql = '''
      CREATE TABLE ${Project.table} (
        $primaryKey     INTEGER      PRIMARY KEY AUTOINCREMENT,
        $colName        TEXT         NOT NULL,
        $colDescription TEXT         NOT NULL,
        $colStatus      TEXT         NOT NULL
          DEFAULT 'active'
          CHECK ($colStatus IN ('plan', 'active', 'archived'))
      )
    ''';

  final int? id;
  final String name;
  final String description;
  final ProjectStatus status;

  Project({
    this.id,
    required this.name,
    required this.description,
    this.status = ProjectStatus.active,
  }) : assert(name.isNotEmpty, 'Project name cannot be empty');

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map[primaryKey] as int?,
      name: map[colName] as String,
      description: map[colDescription] as String,
      status: ProjectStatus.values.byName(map[colStatus] as String)
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) primaryKey: id,
      colName: name,
      colDescription: description,
      colStatus: status.name,
    };
  }
  
  Project copyWith({int? id, String? name, String? description, ProjectStatus? status}) {
    return Project(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        status: status ?? this.status
    );
  }
}
