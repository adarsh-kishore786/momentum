import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/idea.dart';
import 'package:momentum/providers/providers.dart';

class ProjectIdeasNotifier extends AsyncNotifier<List<Idea>> {
  final int projectId;

  ProjectIdeasNotifier(this.projectId);

  @override
  FutureOr<List<Idea>> build() async {
    final repository = await ref.watch(repositoryProvider.future);

    return await repository.getIdeas(projectId);
  }
}

final projectIdeasNotifier = AsyncNotifierProvider.family<ProjectIdeasNotifier, List<Idea>, int>(ProjectIdeasNotifier.new);
