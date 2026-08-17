import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/notifiers/dashboard_notifier.dart';
import 'package:momentum/providers/providers.dart';

class ProjectCreateNotifier extends AsyncNotifier<void> {
  
  @override
  FutureOr<void> build() {}

  Future<int> insertProject(String name, String description) async {
    final project = Project(name: name, description: description);
    final repository = await ref.read(repositoryProvider.future);
    int projectId = await repository.insertProject(project);

    ref.invalidate(dashboardProvider);
    return projectId;
  }
}

final projectCreateProvider = AsyncNotifierProvider<ProjectCreateNotifier, void>(
  ProjectCreateNotifier.new
);
