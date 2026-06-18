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
    final active  = projects.where(
      (p) => p.project.status == ProjectStatus.active
    ).toList();

    final archived = projects.where(
      (p) => p.project.status == ProjectStatus.archived
    ).toList();

    return CustomScrollView(
      slivers: [
        _Header(),
        _SectionLabel('Active', active.length),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => _ProjectCard(item: active[i]),
            childCount: active.length,
          ),
        ),
        _SectionLabel('Archived', archived.length),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => _DormantCard(item: archived[i]),
            childCount: archived.length,
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
        child: Text(
          'Projects',
          style: const TextStyle(
            color: Color(0xFFF0F0F0),
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final int count;

  const _SectionLabel(this.title, this.count);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF444444),
                fontSize: 10,
                letterSpacing: 1.2,
              )),
            Text('$count projects',
              style: const TextStyle(color: Color(0xFF333333), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectWithLastSession item;

  const _ProjectCard({required this.item});

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

class _DormantCard extends ConsumerWidget {
  final ProjectWithLastSession item;

  const _DormantCard({required this.item});

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
            style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 14)),
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
                style: TextStyle(color: Color(0xFF555555), fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }
}
