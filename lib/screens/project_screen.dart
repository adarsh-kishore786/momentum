import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/project_status.dart';
import 'package:momentum/models/session.dart';
import 'package:intl/intl.dart';
import 'package:momentum/notifiers/project_notifier.dart';
import 'package:momentum/notifiers/project_sessions_notifier.dart';
import 'package:momentum/notifiers/session_notifier.dart';
import 'package:momentum/notifiers/tab_reset_notifier.dart';
import 'package:momentum/screens/commons.dart';
import 'package:momentum/screens/session_form.dart';
import 'package:momentum/screens/project_form.dart';

class ProjectScreen extends ConsumerStatefulWidget {
  final int projectId;

  const ProjectScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends ConsumerState<ProjectScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) {
          setState(() => _tabIndex = _tabController.index);
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectProvider(widget.projectId));

    ref.listen<int>(projectTabResetProvider, (prev, next) {
      _tabController.animateTo(0);
    });

    return Scaffold(
      body: state.when(
        loading: () => const _LoadingBody(),
        error: (e, _) => _ErrorBody(error: e),
        data: (project) => _DetailBody(
          project: project,
          tabController: _tabController,
        ),
      ),
      floatingActionButton: state.maybeWhen(
        data: (data) => _tabIndex == 0
            ? FloatingActionButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => SessionForm(project: data),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.add),
              )
            : null,
        orElse: () => null,
      ),
    );
  }
}

// ── Loading / error states ──────────────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        _DetailAppBar(project: null),
        SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CustomScrollView(
      slivers: [
        const _DetailAppBar(project: null),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Failed to load project details. Try again.',
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

// ── Detail body: header + tabs ──────────────────────────────────────────────

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.project,
    required this.tabController,
  });

  final Project project;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return NestedScrollView(
      headerSliverBuilder: (context, _) => [
        _DetailAppBar(project: project),
        SliverToBoxAdapter(child: _ProjectHeader(project: project)),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            TabBar(
              controller: tabController,
              labelColor: cs.primary,
              unselectedLabelColor: cs.secondary,
              dividerColor: cs.tertiary,
              tabs: const [
                Tab(text: 'Sessions'),
                Tab(text: 'Ideas'),
              ],
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: tabController,
        children: [
          _SessionsTab(project),
          _IdeasTab(project),
        ],
      ),
    );
  }
}

class _ProjectHeader extends StatelessWidget {
  const _ProjectHeader({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
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
                    text: ' (archived)',
                    style: TextStyle(color: cs.error, fontSize: 18),
                  ),
              ],
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
    );
  }
}

/// Pins the TabBar under the header inside the NestedScrollView.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) =>
      tabBar != oldDelegate.tabBar;
}

class _DetailAppBar extends ConsumerWidget {
  const _DetailAppBar({required this.project});

  final Project? project;

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
        IconButton(
          icon: const Icon(Icons.edit),
          color: cs.primary,
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => ProjectForm(project: project),
          ),
        ),
        if (project != null && project!.status != ProjectStatus.archived)
          IconButton(
            icon: const Icon(Icons.archive),
            color: cs.onSurface,
            onPressed: () async {
              await ref.read(projectProvider(project!.id!).notifier).archive();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Project archived.')));

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

              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Project unarchived.')));

              Navigator.of(context).pop();
            },
          ),
        IconButton(
          icon: const Icon(Icons.delete),
          color: cs.error,
          onPressed: project == null
              ? null
              : () async {
                  final bool? confirm = await confirmDelete(context);

                  if (confirm == true) {
                    await ref.read(projectProvider(project!.id!).notifier).deleteProject();

                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Project deleted')));
                  }
                },
        ),
      ],
    );
  }
}

// ── Sessions tab ─────────────────────────────────────────────────────────────

class _SessionsTab extends ConsumerWidget {
  const _SessionsTab(this.project);

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
      error: (e, _) => _ErrorBody(error: e),
      loading: () => const _LoadingBody()
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
    if (sessions.isEmpty) {
      return const _EmptyState(message: 'No sessions yet.');
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: sessions.length + 1,
      separatorBuilder: (_, i) => i < sessions.length - 1
          ? const Divider(height: 1, indent: 24, endIndent: 24, color: Color(0xFF1E1E1E))
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

// ── Ideas tab (stub) ─────────────────────────────────────────────────────────

// Placeholder pending IdeaDao / ideaProvider. Expected to mirror
// _SessionsTab: watch an AsyncValue<List<Idea>>, render open ideas
// unchecked and done ideas struck through, with an inline add field
// at the bottom of the list (per spec — no modal, no FAB for ideas).
class _IdeasTab extends StatelessWidget {
  const _IdeasTab(this.project);

  final Project project;

  @override
  Widget build(BuildContext context) {
    return const _EmptyState(message: 'Ideas — coming soon.');
  }
}

// ── Shared empty state ───────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
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
