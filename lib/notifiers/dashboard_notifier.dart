import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/project_status.dart';
import 'package:momentum/models/project_with_last_session.dart';
import 'package:momentum/models/session.dart';
import 'package:momentum/notifiers/history_notifier.dart';
import 'package:momentum/notifiers/project_notifier.dart';
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

  Future<void> logSession(int durationMinutes, String notes, DateTime date, int projectId) async {
    final session = Session(
      projectId: projectId,
      date: date,
      durationMinutes: durationMinutes,
      note: notes
    );

    final project = await ref.read(repositoryProvider).getProjectById(projectId);

    if (project.status != ProjectStatus.active) {
      await ref.read(repositoryProvider).updateProject(project.copyWith(status: ProjectStatus.active));
    }
    await ref.read(repositoryProvider).insertSession(session);
    ref.invalidate(historyProvider);
    ref.invalidate(projectProvider);
    ref.invalidateSelf();
  }
}

final dashboardProvider = 
  AsyncNotifierProvider<DashboardNotifier, List<ProjectWithLastSession>>(
    DashboardNotifier.new
  );
