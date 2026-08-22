import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/session.dart';
import 'package:momentum/notifiers/project_sessions_notifier.dart';
import 'package:momentum/notifiers/session_notifier.dart';
import 'package:momentum/screens/commons.dart';
import 'package:momentum/screens/project_screen_commons.dart';
import 'package:momentum/screens/session_form.dart';

class ProjectSessionsScreen extends ConsumerWidget {
  const ProjectSessionsScreen(this.project, {super.key});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsState = ref.watch(projectSessionsProvider(project.id!));
    final sessionsNotifier = ref.watch(projectSessionsProvider(project.id!).notifier);

    return sessionsState.when(
      data: (sessions) => _SessionsList(
          project: project,
          sessions: sessions,
          hasMore: sessionsNotifier.hasMore(),
          onLoadMore: sessionsNotifier.loadMore,
        ),
      error: (e, _) => ErrorBody(error: e),
      loading: () => const LoadingBody()
    );
  }
}

class _SessionsList extends ConsumerWidget {
  final Project project;
  final List<Session> sessions;
  final bool hasMore;
  final VoidCallback onLoadMore;

  const _SessionsList({
    required this.project,
    required this.sessions,
    required this.hasMore,
    required this.onLoadMore
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    if (sessions.isEmpty) {
      return const EmptyState(message: 'No sessions yet.');
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: sessions.length + 1,
      separatorBuilder: (_, i) => i < sessions.length - 1
          ? Divider(height: 1, indent: 24, endIndent: 24, color: cs.outlineVariant)
          : const SizedBox.shrink(),
      itemBuilder: (context, i) {
        if (i == sessions.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: hasMore
                ? ElevatedButton(
                    onPressed: onLoadMore,
                    child: const Text('Load More'),
                  )
                : Center(
                    child: Text(
                      'Reached the end',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ),
          );
        }
        return _SessionTile(project: project, session: sessions[i]);
      },
    );
  }
}

class _SessionTile extends ConsumerWidget {
  const _SessionTile({required this.project, required this.session});

  final Project project;
  final Session session;

  static final _dateFmt = DateFormat('EEE, d MMM');
  static final _todayFmt = DateFormat('d MMM');

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final localDate = date.toLocal();
    if (localDate.year == today.year &&
        localDate.month == today.month &&
        localDate.day == today.day) {
      return 'Today, ${_todayFmt.format(localDate)}';
    }
    return _dateFmt.format(localDate);
  }

  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(session.date),
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                _formatDuration(session.durationMinutes),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  session.note,
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    color: cs.onSurface,
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => SessionForm(project: project, session: session),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: cs.error,
                    onPressed: () async {
                      final bool? confirm = await confirmDelete(context, item: 'session');

                      if (confirm == true) {
                        await ref.read(sessionProvider(session.id!).notifier).delete();

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Session deleted')));
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
