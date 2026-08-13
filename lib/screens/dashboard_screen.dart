import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:momentum/models/project_status.dart';
import 'package:momentum/models/project_with_last_session.dart';
import 'package:momentum/notifiers/dashboard_notifier.dart';
import 'package:momentum/notifiers/tab_reset_notifier.dart';
import 'package:momentum/routing/routes.dart';
import 'package:momentum/screens/project_form.dart';
import 'package:momentum/screens/session_form.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
  with SingleTickerProviderStateMixin {

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);

    ref.listen<int>(dashboardTabResetProvider, (prev, next) {
      _tabController.animateTo(0);
    });

    return SafeArea(
      child: state.when(
        loading: () => const Center(
          child: CircularProgressIndicator()
        ),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
        data: (projects) => _Dashboard(projects: projects, tabController: _tabController),
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  final List<ProjectWithLastSession> projects;
  final TabController tabController;

  const _Dashboard({required this.projects, required this.tabController});

  @override
  Widget build(BuildContext context) {
    final planned = projects.where(
      (p) => p.project.status == ProjectStatus.planned
    ).toList();

    final active  = projects.where(
      (p) => p.project.status == ProjectStatus.active
    ).toList();

    final archived = projects.where(
      (p) => p.project.status == ProjectStatus.archived
    ).toList();

    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: tabController.index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        tabController.animateTo(0);
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: TabBar(
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.secondary,
            controller: tabController,
            dividerColor: colorScheme.tertiary,
            tabs: [
              Tab(text: "Active"),
              Tab(text: "Planned"),
              Tab(text: "Archived"),
            ],
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(
            top: 10,
            bottom: 56 + 16 + MediaQuery.of(context).padding.bottom,
          ),
          child: TabBarView(
            controller: tabController,
            children: [
              _ListCard(projects: active, projectStatus: ProjectStatus.active),
              _ListCard(projects: planned, projectStatus: ProjectStatus.planned),
              _ListCard(projects: archived, projectStatus: ProjectStatus.archived),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const ProjectForm(),
          ),
          backgroundColor: colorScheme.primary,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  final List<ProjectWithLastSession> projects;
  final ProjectStatus projectStatus;

  const _ListCard({required this.projects, required this.projectStatus});

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return Center(
        child: Text(
          "No ${projectStatus.name} projects!",
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 20,
          ),
        ),
      );
    }
    
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) =>
              _ProjectCard(item: projects[i], status: projectStatus),
            childCount: projects.length,
          ),
        ),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectWithLastSession item;
  final ProjectStatus status;

  const _ProjectCard({required this.item, required this.status});

  Color get _boxColor {
    if (status == ProjectStatus.archived) {
      return const Color(0xFF222222);
    }

    if (status == ProjectStatus.planned) {
      return const Color(0x22222222);
    }

    const activeColor  = Color(0xFFC8F53A);
    const fadingColor  = Color(0xFFF5C23A);
    const dormantColor = Color(0xFFF5603A);

    if (item.lastSession == null) return dormantColor;
    final days = DateTime.now().difference(item.lastSession!.date).inDays;
    if (days <= 7)  return activeColor;
    if (days <= 14) return fadingColor;
    return dormantColor;
  }

  String get _recencyLabel {
    if (status == ProjectStatus.archived || status == ProjectStatus.planned) {
      return '';
    }

    if (item.lastSession == null) return 'never';
    final days = DateTime.now().difference(item.lastSession!.date).inDays;
    if (days == 0) return 'today';
    if (days == 1) return 'yesterday';
    return '$days days ago';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color boxDecorationColor;
    String buttonText;
    Color buttonTextColor = colorScheme.primary;

    switch (status) {
      case ProjectStatus.active: 
        boxDecorationColor = colorScheme.surface;
        buttonText = "Log";

      case ProjectStatus.archived:
        boxDecorationColor = colorScheme.surfaceDim;
        buttonTextColor = colorScheme.onSurface;
        buttonText = "Revive";

      case ProjectStatus.planned:
        boxDecorationColor = colorScheme.surfaceDim;
        buttonText = "Start";
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 10),
      child: GestureDetector(
        onTap: () {
          context.push(
            Routes.project.replaceAll(":id", item.project.id!.toString())
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: boxDecorationColor,
            borderRadius: BorderRadius.circular(14),
            border: Border(left: BorderSide(color: _boxColor, width: 3)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.project.name,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        )
                      ),

                      if (item.lastSession != null) ...[
                        SizedBox(
                          height: 30,
                          width: 200,
                          child: Text(
                            item.lastSession!.note,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 10
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 10,
                    children: [
                      if (status == ProjectStatus.active)
                        Text(
                          _recencyLabel,
                          style: TextStyle(
                            color: _boxColor,
                            fontSize: 13
                          )
                        ),

                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll<Color>(
                            colorScheme.primary.withValues(alpha: 0.2)
                          ),
                        ),
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => SessionForm(project: item.project)
                        ),
                        child: Text(
                          buttonText,
                          style: TextStyle(color: buttonTextColor),
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
