import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:momentum/routing/routes.dart';
import 'package:momentum/screens/commons.dart';
import 'package:momentum/screens/dashboard_screen.dart';
import 'package:momentum/screens/history_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.dashboard,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MomentumFooter(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.dashboard, builder: (_, _) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.history, builder: (_, _) => const HistoryScreen()),
          ])
        ]
      ) 
    ]
  );
});
