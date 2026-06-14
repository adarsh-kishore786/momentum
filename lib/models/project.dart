import 'package:momentum/models/project_status.dart';

class Project {
  final int? id;
  final String name;
  final String description;
  final ProjectStatus status;

  static const String table = "project";
  static const String primaryKey = "id";

  Project({
    this.id,
    required this.name,
    required this.description,
    this.status = ProjectStatus.active,
  }) : assert(name.isNotEmpty, 'Project name cannot be empty');

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      status: ProjectStatus.values.byName(map['status'] as String)
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'status': status.name,
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
