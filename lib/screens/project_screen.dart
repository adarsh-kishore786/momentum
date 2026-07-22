import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/project_status.dart';
import 'package:momentum/models/session.dart';
import 'package:intl/intl.dart';
import 'package:momentum/notifiers/project_notifier.dart';
import 'package:momentum/screens/add_session.dart';
import 'package:momentum/screens/commons.dart';

class ProjectScreen extends ConsumerWidget {
  const ProjectScreen({
    super.key,
    required this.projectId,
  });

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectProvider(projectId));

    return Scaffold(
      body: state.when(
        loading: () => const _LoadingBody(),
        error: (e, _) => _ErrorBody(error: e),
        data: (data) => Scaffold(
          body: _DetailBody(project: data.project, sessions: data.sessions),
          floatingActionButton: FloatingActionButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => AddSession(project: data.project),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(Icons.add),
          ),
        )
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        _DetailAppBar(project: null, sessions: []),
        SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CustomScrollView(
      slivers: [
        const _DetailAppBar(project: null, sessions: []),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Failed to load sessions.\n$error',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.error, fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Data ──────────────────────────────────────────────────────────────────────

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.project, required this.sessions});

  final Project project;
  final List<Session> sessions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        _DetailAppBar(project: project, sessions: sessions),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: project.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                      letterSpacing: -0.02,
                    ),
                    children: <InlineSpan>[
                      if (project.status == ProjectStatus.archived)
                        TextSpan(
                          text: " (archived)",
                          style: TextStyle(color: cs.error, fontSize: 18)
                        )

                    ]
                  ),
                ),
                if (project.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    project.description,
                    style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ),
        _SessionsHeader(count: sessions.length),
        if (sessions.isEmpty)
          const _EmptySessionsSliver()
        else
          _SessionList(sessions: sessions),

        if (ref.read(projectProvider(project.id!).notifier).hasMore())
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () async {
                  await ref.read(projectProvider(project.id!).notifier).loadMore();
                },
                child: const Text('Load More'),
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: null, 
                onLongPress: null,
                child: const Text('Reached the end'),
              ),
            ),
          )
      ],
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _DetailAppBar extends ConsumerWidget {
  const _DetailAppBar({required this.project, required this.sessions});

  final Project? project;
  final List<Session> sessions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return SliverAppBar(
      pinned: true,
      forceElevated: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: cs.onSurfaceVariant,
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        if (project != null && project!.status != ProjectStatus.archived) 
          IconButton(
            icon: const Icon(Icons.archive),
            color: cs.onSurface,
            onPressed: () async {
              await ref.read(projectProvider(project!.id!).notifier).archive();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Project archived.")
                ),
              );

              Navigator.of(context).pop();
            },
          ),

        if (project != null && project!.status == ProjectStatus.archived)
          IconButton(
            icon: const Icon(Icons.unarchive),
            color: cs.onSurface,
            onPressed: () async {
              await ref.read(projectProvider(project!.id!).notifier).unarchive();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Project unarchived.")
                ),
              );

              Navigator.of(context).pop();
            },
          ),

        IconButton(
          icon: const Icon(Icons.delete),
          color: cs.error,
          onPressed: () async {
            bool? confirm = await confirmDelete(context);

            if (confirm == true) {
              await ref.read(projectProvider(project!.id!).notifier).delete();
              
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }
          },
        ),
      ],
    );
  }
}

class _SessionsHeader extends StatelessWidget {
  const _SessionsHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        child: Text(
          'SESSIONS',
          style: TextStyle(
            fontSize: 10,
            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            letterSpacing: 0.12,
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptySessionsSliver extends StatelessWidget {
  const _EmptySessionsSliver();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Text(
          'No sessions yet.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: cs.onSurfaceVariant.withValues(alpha: 0.4),
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

// ── Session list ──────────────────────────────────────────────────────────────

class _SessionList extends StatelessWidget {
  const _SessionList({required this.sessions});

  final List<Session> sessions;

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: sessions.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        indent: 24,
        endIndent: 24,
        color: const Color(0xFF1E1E1E),
      ),
      itemBuilder: (context, i) => _SessionTile(session: sessions[i]),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

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
  Widget build(BuildContext context) {
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
          const SizedBox(height: 5),
          Text(
            session.note,
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
