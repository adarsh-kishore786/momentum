import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/session.dart';
import 'package:momentum/notifiers/dashboard_notifier.dart';
import 'package:momentum/notifiers/project_sessions_notifier.dart';
import 'package:momentum/providers/providers.dart';

class SessionNotifier extends AsyncNotifier<void> {
  final int sessionId;

  SessionNotifier(this.sessionId);

  @override
  FutureOr<void> build() {}

  Future<void> updateSession(Session session) async {
    final repository = await ref.read(repositoryProvider.future);
    if (!ref.mounted) return;

    await repository.updateSession(session);
    if (!ref.mounted) return;

    ref.invalidate(dashboardProvider);
    ref.invalidate(projectSessionsProvider);
  }

  Future<void> delete() async {
    final repository = await ref.read(repositoryProvider.future);
    if (!ref.mounted) return;

    await repository.deleteSession(sessionId);

    ref.invalidate(dashboardProvider);
    ref.invalidate(projectSessionsProvider);
  }
}

final sessionProvider = AsyncNotifierProvider.family<SessionNotifier, void, int>
(SessionNotifier.new);
