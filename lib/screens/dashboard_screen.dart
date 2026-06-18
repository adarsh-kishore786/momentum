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
            (context, i) {
              switch (projectStatus) {
                case ProjectStatus.active: 
                  return _ActiveProjectCard(item: projects[i]);

                case ProjectStatus.archived:
                  return _ArchivedProjectCard(item: projects[i]);

                case ProjectStatus.planned:
                  return _ActiveProjectCard(item: projects[i]);
              }
            },
            childCount: projects.length,
          ),
        ),
      ],
    );
  }
}

class _ActiveProjectCard extends StatelessWidget {
  final ProjectWithLastSession item;

  const _ActiveProjectCard({required this.item});

  Color get _recencyColor {
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
    if (item.lastSession == null) return 'never';
    final days = DateTime.now().difference(item.lastSession!.date).inDays;
    if (days == 0) return 'today';
    if (days == 1) return 'yesterday';
    return '$days days ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: _recencyColor, width: 3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.project.name,
                style: const TextStyle(
                  color: Color(0xFFE8E8E8),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                )),
              Text(_recencyLabel,
                style: TextStyle(color: _recencyColor, fontSize: 10)),
            ],
          ),
          if (item.lastSession != null) ...[
            const SizedBox(height: 6),
            Text(
              item.lastSession!.note,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF555555), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _ArchivedProjectCard extends ConsumerWidget {
  final ProjectWithLastSession item;

  const _ArchivedProjectCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF222222)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(item.project.name,
            style: const TextStyle(color: Color(0xFFEEDDCC), fontSize: 14)),
          GestureDetector(
            onTap: () {
              // revive — will wire to repository in next step
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2A2A2A)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Revive',
                style: TextStyle(
                  color: Color(0xFFEEDDCC),
                  fontSize: 12
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
