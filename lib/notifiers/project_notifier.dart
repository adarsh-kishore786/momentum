import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/project_detail.dart';
import 'package:momentum/models/project_status.dart';
import 'package:momentum/models/session.dart';
import 'package:momentum/notifiers/dashboard_notifier.dart';
import 'package:momentum/notifiers/history_notifier.dart';
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

  Future<void> delete() async {
    final repository = await ref.watch(repositoryProvider.future);
    if (!ref.mounted) return;

    await repository.deleteProject(projectId);
    if (!ref.mounted) return;

    ref.invalidate(dashboardProvider);
    ref.invalidate(historyProvider);
    ref.invalidateSelf();
  }

  Future<void> archive() async {
    final repository = await ref.watch(repositoryProvider.future);
    final project = await repository.getProjectById(projectId);
    if (!ref.mounted) return;

    if (project.status != ProjectStatus.archived) {
      await repository.updateProject(project.copyWith(status: ProjectStatus.archived));
      if (!ref.mounted) return;
    }

    ref.invalidate(dashboardProvider);
    ref.invalidateSelf();
  }

  Future<void> unarchive() async {
    final repository = await ref.watch(repositoryProvider.future);
    final project = await repository.getProjectById(projectId);
    if (!ref.mounted) return;

    if (project.status == ProjectStatus.archived) {
      await repository.updateProject(project.copyWith(status: ProjectStatus.active));
      if (!ref.mounted) return;
    }

    ref.invalidate(dashboardProvider);
    ref.invalidateSelf();
  }
}

final projectProvider = AsyncNotifierProvider.family<ProjectNotifier, ProjectDetail, int>
  (ProjectNotifier.new);
