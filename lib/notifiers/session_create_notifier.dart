import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/project_status.dart';
import 'package:momentum/models/session.dart';
import 'package:momentum/notifiers/dashboard_notifier.dart';
import 'package:momentum/notifiers/project_sessions_notifier.dart';
import 'package:momentum/providers/providers.dart';

class SessionCreateNotifier extends AsyncNotifier<void> {
  
  @override
  FutureOr<void> build() {}

  Future<void> logSession(
    int durationMinutes,
    String notes,
    DateTime date,
    int projectId
  ) async {

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

    ref.invalidate(dashboardProvider);
    ref.invalidate(projectSessionsProvider);
  }
}

final sessionCreateProvider = AsyncNotifierProvider<SessionCreateNotifier, void>
(SessionCreateNotifier.new);
