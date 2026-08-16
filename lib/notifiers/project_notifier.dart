import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/project_status.dart';
import 'package:momentum/notifiers/dashboard_notifier.dart';
import 'package:momentum/providers/providers.dart';

class ProjectNotifier extends AsyncNotifier<Project> {
  final int projectId;

  ProjectNotifier(this.projectId);

  @override
  FutureOr<Project> build() async {
    final repository = await ref.watch(repositoryProvider.future);
    return await repository.getProjectById(projectId);
  }

  Future<void> delete() async {
    final repository = await ref.read(repositoryProvider.future);
    if (!ref.mounted) return;

    await repository.deleteProject(projectId);
    if (!ref.mounted) return;

    ref.invalidate(dashboardProvider);
  }

  Future<void> archive() async {
    final repository = await ref.read(repositoryProvider.future);
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
    final repository = await ref.read(repositoryProvider.future);
    final project = await repository.getProjectById(projectId);
    if (!ref.mounted) return;

    if (project.status == ProjectStatus.archived) {

      ProjectStatus status = ProjectStatus.active;
      final val = await repository.isProjectActive(projectId);

      if (val == false) status = ProjectStatus.planned;

      await repository.updateProject(project.copyWith(status: status));
      if (!ref.mounted) return;
    }

    ref.invalidate(dashboardProvider);
    ref.invalidateSelf();
  }
}

final projectProvider = AsyncNotifierProvider.family<ProjectNotifier, Project, int>
  (ProjectNotifier.new);
