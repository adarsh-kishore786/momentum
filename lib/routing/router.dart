import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:momentum/notifiers/project_tab_reset_notifier.dart';
import 'package:momentum/routing/routes.dart';
import 'package:momentum/screens/dashboard_screen.dart';
import 'package:momentum/screens/history_screen.dart';
import 'package:momentum/screens/project_screen.dart';

class MomentumFooter extends ConsumerWidget {
  final Widget child;
  final String currentPath;

  const MomentumFooter({required this.child, required this.currentPath, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHistory = currentPath == Routes.history;
    
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: isHistory ? 1 : 0,
        onTap: (index) {
          if (index == 1 && !isHistory) {
            context.push(Routes.history);
          } else if (index == 0) {
            if (isHistory) {
              context.canPop() ? context.pop() : context.go(Routes.dashboard);
            } else {
              ref.read(projectTabResetProvider.notifier).state++;
            }
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Projects'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
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
        builder: (context, state, child) => MomentumFooter(currentPath: state.uri.path, child: child),
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
