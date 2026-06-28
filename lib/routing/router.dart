import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:momentum/routing/routes.dart';
import 'package:momentum/screens/dashboard_screen.dart';
import 'package:momentum/screens/history_screen.dart';
import 'package:momentum/screens/project_screen.dart';

class MomentumFooter extends StatelessWidget {
  final StatefulNavigationShell shell;
  const MomentumFooter({required this.shell, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: shell.currentIndex,
        onTap: (index) => shell.goBranch(
          index,
          initialLocation: index == shell.currentIndex
        ),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Projects"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.dashboard,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MomentumFooter(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.dashboard, builder: (_, _) => DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.history, builder: (_, _) => const HistoryScreen()),
          ])
        ]
      ),
      GoRoute(
        path: Routes.project,
        builder: (_, state) {
          final projectId = int.parse(state.pathParameters['id']!);
          return ProjectScreen(projectId: projectId);
        }
      ),
    ]
  );
});
