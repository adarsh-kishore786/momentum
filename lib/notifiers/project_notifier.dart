import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/providers/providers.dart';

class ProjectNotifier extends FamilyAsyncNotifier<Project, int> {
  @override
  FutureOr<Project> build(int projectId) async {
    final result = await Future.wait([
      ref.watch(repositoryProvider).getProjectById(projectId)
    ]);

    return result[0];
  }
}
