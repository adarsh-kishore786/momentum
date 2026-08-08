import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/notifiers/dashboard_notifier.dart';
import 'package:momentum/notifiers/project_notifier.dart';
import 'package:momentum/providers/providers.dart';

class SessionNotifier extends AsyncNotifier<void> {
  final int sessionId;

  SessionNotifier(this.sessionId);

  @override
  FutureOr<void> build() {}

  Future<void> delete() async {
    final repository = await ref.read(repositoryProvider.future);
    if (!ref.mounted) return;

    await repository.deleteSession(sessionId);

    ref.invalidate(dashboardProvider);
    ref.invalidate(projectProvider);
  }
}

final sessionProvider = AsyncNotifierProvider.family<SessionNotifier, void, int>
(SessionNotifier.new);
