import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/project_status.dart';
import 'package:momentum/models/project_with_last_session.dart';
import 'package:momentum/notifiers/dashboard_notifier.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "MOMENTUM",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        
      ),
      body: SafeArea(
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
          ),
          data: (projects) => _Dashboard(projects: projects),
        ),
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  final List<ProjectWithLastSession> projects;

  const _Dashboard({required this.projects});

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

    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            dividerColor: Colors.purple,
            tabs: [
              Tab(text: "Active"),
              Tab(text: "Archived"),
              Tab(text: "Planned")
            ],
          ),
          
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: TabBarView(
            children: [
              _ListCard(projects: active, projectStatus: ProjectStatus.active),
              _ListCard(projects: archived, projectStatus: ProjectStatus.archived),
              _ListCard(projects: planned, projectStatus: ProjectStatus.planned),
            ],
          ),
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
            color: Colors.white60,
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
    Color boxDecorationColor;
    String buttonText;

    switch (status) {
      case ProjectStatus.active: 
        boxDecorationColor = const Color(0xFF1C1C1C);
        buttonText = "Log";

      case ProjectStatus.archived:
        boxDecorationColor = const Color(0xFF181818);
        buttonText = "Revive";

      case ProjectStatus.planned:
        boxDecorationColor = const Color(0xFF1A1A1A);
        buttonText = "Start";
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 10),
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
                    style: const TextStyle(
                      color: Color(0xFFE8E8E8),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    )
                  ),

                  if (item.lastSession != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.lastSession!.note,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 14
                      ),
                    ),
                  ],
                ],
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 10,
                children: [
                  if (status == ProjectStatus.active)
                    Text(
                      _recencyLabel,
                      style: TextStyle(
                        color: _boxColor,
                        fontSize: 16
                      )
                    ),

                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll<Color>(Color(0x20000000)),
                      
                    ),
                    onPressed: () {},
                    child: Text(
                      buttonText,
                    )
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
