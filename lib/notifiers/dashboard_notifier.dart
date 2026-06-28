import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/project_with_last_session.dart';
import 'package:momentum/providers/providers.dart';

class DashboardNotifier extends AsyncNotifier<List<ProjectWithLastSession>> {
  @override
  FutureOr<List<ProjectWithLastSession>> build() {
    final repository = ref.watch(repositoryProvider);
    return repository.getProjectsWithLastSession();
  }

  void refresh() => ref.invalidateSelf();

  Future<void> insertProject(String name, String description) async {
    final project = Project(name: name, description: description);
    await ref.read(repositoryProvider).insertProject(project);
    ref.invalidateSelf();
  }
}

final dashboardProvider = 
  AsyncNotifierProvider<DashboardNotifier, List<ProjectWithLastSession>>(
    DashboardNotifier.new
  );
