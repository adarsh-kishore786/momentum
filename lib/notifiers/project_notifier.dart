import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/constants.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/project_detail.dart';
import 'package:momentum/models/project_status.dart';
import 'package:momentum/models/session.dart';
import 'package:momentum/notifiers/dashboard_notifier.dart';
import 'package:momentum/notifiers/history_notifier.dart';
import 'package:momentum/providers/providers.dart';

class ProjectNotifier extends AsyncNotifier<ProjectDetail> {
  final int projectId;
  int _offset = 0;
  bool _hasMore = true;
  bool _isLoading = false;

  ProjectNotifier(this.projectId);

  @override
  FutureOr<ProjectDetail> build() async {
    _offset = 0;
    _hasMore = true;
    _isLoading = false;

    final repository = await ref.watch(repositoryProvider.future);

    final results = await Future.wait([
      repository.getProjectById(projectId),
      repository.getProjectSessions(projectId, _offset)
    ]);

    _offset += Constants.limit;

    return ProjectDetail(
      project: results[0] as Project,
      sessions: results[1] as List<Session>
    );
  }

  FutureOr<List<Session>> _fetch() async {
    final repository = await ref.read(repositoryProvider.future);

    final projectSessions = await repository.getProjectSessions(projectId, _offset);

    if (projectSessions.isNotEmpty) {
      _offset += Constants.limit;
    } else {
      _hasMore = false;
    }
     return projectSessions;
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    try {
      final moreSessions = await _fetch();

      state = AsyncData(
        ProjectDetail(
          project: state.value!.project,
          sessions: [...state.value!.sessions, ...moreSessions]
        )
      );
    } finally {
      _isLoading = false;
    }
  }

  Future<void> delete() async {
    final repository = await ref.read(repositoryProvider.future);
    if (!ref.mounted) return;

    await repository.deleteProject(projectId);
    if (!ref.mounted) return;

    ref.invalidate(dashboardProvider);
    ref.invalidate(historyProvider);
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

  bool hasMore() => _hasMore;
}

final projectProvider = AsyncNotifierProvider.family<ProjectNotifier, ProjectDetail, int>
  (ProjectNotifier.new);
