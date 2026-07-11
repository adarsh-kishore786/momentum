import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/project_detail.dart';
import 'package:momentum/models/session.dart';
import 'package:momentum/providers/providers.dart';

class ProjectNotifier extends AsyncNotifier<ProjectDetail> {
  final int projectId;

  ProjectNotifier(this.projectId);

  @override
  FutureOr<ProjectDetail> build() async {
    final repository = await ref.watch(repositoryProvider.future);

    final results = await Future.wait([
      repository.getProjectById(projectId),
      repository.getProjectSessions(projectId)
    ]);

    return ProjectDetail(
      project: results[0] as Project,
      sessions: results[1] as List<Session>
    );
  }
}

final projectProvider = AsyncNotifierProvider.family<ProjectNotifier, ProjectDetail, int>
  (ProjectNotifier.new);
