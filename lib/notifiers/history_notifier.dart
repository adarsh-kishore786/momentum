import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/history_state.dart';
import 'package:momentum/models/session_cursor.dart';
import 'package:momentum/providers/providers.dart';

class HistoryNotifier extends AsyncNotifier<HistoryState> {
  SessionCursor? _cursor;
  bool _hasMore = true;

  @override
  FutureOr<HistoryState> build() async {
    _cursor = null;
    _hasMore = true;
    return _fetch();
  }

  FutureOr<HistoryState> _fetch() async {
    final sessions = await ref
      .read(repositoryProvider)
      .getAllSessions(after: _cursor);

    if (sessions.isNotEmpty) {
      final last = sessions.last;
      _cursor = SessionCursor(date: last.session.date, id: last.session.id!);
    }

    _hasMore = sessions.length == 30; // default limit

    return HistoryState(sessions: sessions, hasMore: _hasMore);
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    final next = await _fetch();

    state = AsyncData(HistoryState(
      sessions: [...state.value!.sessions, ...next.sessions],
      hasMore: next.hasMore
    ));
  }

  void refresh() => ref.invalidateSelf();
}

final historyProvider = AsyncNotifierProvider<HistoryNotifier, HistoryState>(
  HistoryNotifier.new
);
