import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/constants.dart';
import 'package:momentum/models/session.dart';
import 'package:momentum/providers/providers.dart';

class ProjectSessionsNotifier extends AsyncNotifier<List<Session>> {
  final int projectId;
  int _offset = 0;
  bool _hasMore = true;
  bool _isLoading = false;

  ProjectSessionsNotifier(this.projectId);

  @override
  FutureOr<List<Session>> build() async {
    _offset = 0;
    _hasMore = true;
    _isLoading = false;

    final repository = await ref.watch(repositoryProvider.future);

    final sessions = await repository.getProjectSessions(projectId, _offset);

    _offset += Constants.limit;

    return sessions;
  }

  FutureOr<List<Session>> _fetch() async {
    final repository = await ref.read(repositoryProvider.future);

    final sessions = await repository.getProjectSessions(projectId, _offset);

    if (sessions.isNotEmpty) {
      _offset += Constants.limit;
    } else {
      _hasMore = false;
    }
    return sessions;
  }

  FutureOr<void> loadMore() async {
    if (!_hasMore || _isLoading) return;

    _isLoading = true;

    try {
      final moreSessions = await _fetch();

      state = AsyncData([...state.value ?? [], ...moreSessions]);
    } finally {
      _isLoading = false;
    }
  }

  bool hasMore() => _hasMore;
}

final projectSessionsProvider = AsyncNotifierProvider.family<ProjectSessionsNotifier, List<Session>, int>
(ProjectSessionsNotifier.new);
