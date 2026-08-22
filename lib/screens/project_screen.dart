import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/project_status.dart';
import 'package:momentum/notifiers/project_notifier.dart';
import 'package:momentum/notifiers/tab_reset_notifier.dart';
import 'package:momentum/screens/project_ideas_screen.dart';
import 'package:momentum/screens/project_screen_commons.dart';
import 'package:momentum/screens/project_sessions_screen.dart';
import 'package:momentum/screens/session_form.dart';

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
        loading: () => const LoadingBody(),
        error: (e, _) => ErrorBody(error: e),
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
      bottomSheet: state.maybeWhen(
        data: (data) => _tabIndex == 1
            ? Material(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: AddIdeaField(projectId: data.id!),
              )
            : null,
        orElse: () => null,
      ),
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
        DetailAppBar(project: project),
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
          ProjectSessionsScreen(project),
          ProjectIdeasScreen(project),
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
