import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/project_status.dart';
import 'package:momentum/models/project_with_last_session.dart';
import 'package:momentum/models/session.dart';
import 'package:momentum/notifiers/project_notifier.dart';
import 'package:momentum/providers/providers.dart';

class DashboardNotifier extends AsyncNotifier<List<ProjectWithLastSession>> {
  @override
  FutureOr<List<ProjectWithLastSession>> build() async {
    final repository = await ref.watch(repositoryProvider.future);
    return repository.getProjectsWithLastSession();
  }

  void refresh() => ref.invalidateSelf();

  Future<void> insertProject(String name, String description) async {
    final project = Project(name: name, description: description);
    final repository = await ref.read(repositoryProvider.future);
    await repository.insertProject(project);

    ref.invalidateSelf();
  }
  
  Future<void> updateProject(Project newProject) async {
    final repository = await ref.read(repositoryProvider.future);
    if (!ref.mounted) return;

    await repository.updateProject(newProject);
    if (!ref.mounted) return;

    ref.invalidate(projectProvider);
    ref.invalidateSelf();
  }

  Future<void> logSession(int durationMinutes, String notes, DateTime date, int projectId) async {
    final session = Session(
      projectId: projectId,
      date: date,
      durationMinutes: durationMinutes,
      note: notes
    );

    final repository = await ref.read(repositoryProvider.future);
    final project = await repository.getProjectById(projectId);
    if (!ref.mounted) return;

    if (project.status != ProjectStatus.active) {
      await repository.updateProject(project.copyWith(status: ProjectStatus.active));
      if (!ref.mounted) return;
    }
    await repository.insertSession(session);
    if (!ref.mounted) return;

    ref.invalidate(projectProvider);
    ref.invalidateSelf();
  }
}

final dashboardProvider = 
  AsyncNotifierProvider<DashboardNotifier, List<ProjectWithLastSession>>(
    DashboardNotifier.new
  );
