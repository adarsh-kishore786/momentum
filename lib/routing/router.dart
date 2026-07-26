import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:momentum/notifiers/project_tab_reset_notifier.dart';
import 'package:momentum/routing/routes.dart';
import 'package:momentum/screens/about_screen.dart';
import 'package:momentum/screens/backup_screen.dart';
import 'package:momentum/screens/dashboard_screen.dart';
import 'package:momentum/screens/feedback_screen.dart';
import 'package:momentum/screens/more_screen.dart';
import 'package:momentum/screens/project_screen.dart';
import 'package:momentum/screens/support_screen.dart';

class MomentumFooter extends ConsumerWidget {
  final Widget child;
  final String currentPath;

  const MomentumFooter({required this.child, required this.currentPath, super.key});

  int getIndexFromPath() {
    if (currentPath == Routes.dashboard) return 0;
    if (currentPath == Routes.more) return 1;

    return -1; // Should never happen
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int currentIndex = getIndexFromPath();
   
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 1 && currentIndex != 1) {
            context.push(Routes.more);
          } else if (index == 0) {
            if (currentIndex != 0) {
              context.canPop() ? context.pop() : context.go(Routes.dashboard);
            } else {
              ref.read(projectTabResetProvider.notifier).state++;
            }
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Projects'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More')
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
            GoRoute(path: Routes.more, builder: (_, _) => MoreScreen()),
          ]),
        ]
      ),
      GoRoute(
        path: Routes.project,
        builder: (_, state) {
          final projectId = int.parse(state.pathParameters['id']!);
          return ProjectScreen(projectId: projectId);
        }
      ),
      GoRoute(
        path: Routes.backup,
        builder: (_, _) => BackupScreen()
      ),
      GoRoute(
        path: Routes.about,
        builder: (_, _) => AboutScreen()
      ),
      GoRoute(
        path: Routes.feedback,
        builder: (_, _) => FeedbackScreen()
      ),
      GoRoute(
        path: Routes.support,
        builder: (_, _) => SupportScreen()
      ),
    ]
  );
});
