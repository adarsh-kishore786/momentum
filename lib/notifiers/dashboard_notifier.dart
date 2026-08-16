import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/project_with_last_session.dart';
import 'package:momentum/providers/providers.dart';

class DashboardNotifier extends AsyncNotifier<List<ProjectWithLastSession>> {
  @override
  FutureOr<List<ProjectWithLastSession>> build() async {
    final repository = await ref.watch(repositoryProvider.future);
    return repository.getProjectsWithLastSession();
  }
}

final dashboardProvider = 
  AsyncNotifierProvider<DashboardNotifier, List<ProjectWithLastSession>>(
    DashboardNotifier.new
  );
