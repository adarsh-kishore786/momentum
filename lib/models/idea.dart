import 'package:momentum/models/idea_state.dart';

class Idea {
  final int? id;
  final int projectId;
  final String description;
  final IdeaState state;

  static const String table = "idea";
  static const String primaryKey = "id";

  Idea({
    this.id,
    required this.projectId,
    required this.description,
    this.state = IdeaState.open
  }) : assert(description.isNotEmpty, 'Idea description cannot be empty'),
       assert(projectId > 0, 'projectId must be a valid ID');

  factory Idea.fromMap(Map<String, dynamic> map) {
    return Idea(
      id: map['id'] as int?,
      projectId: map['projectId'] as int,
      description: map['description'] as String,
      state: IdeaState.values.byName(map['state'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'projectId': projectId,
      'description': description,
      'state': state.name,
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
