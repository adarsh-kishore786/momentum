import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/providers/providers.dart';

class ProjectNotifier extends AsyncNotifier<Project> {
  final int projectId;

  ProjectNotifier(this.projectId);

  @override
  FutureOr<Project> build() async {
    final result = await Future.wait([
      ref.watch(repositoryProvider).getProjectById(projectId)
    ]);

    return result[0];
  }
}

final projectNotifier = AsyncNotifierProvider.family<ProjectNotifier, Project, int>
  (ProjectNotifier.new);
