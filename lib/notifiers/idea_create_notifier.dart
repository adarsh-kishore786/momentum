import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/idea.dart';
import 'package:momentum/notifiers/project_ideas_notifier.dart';
import 'package:momentum/providers/providers.dart';

class IdeaCreateNotifier extends AsyncNotifier<void> {
  
  @override
  FutureOr<void> build() {}

  Future<void> insertIdea(
    String description,
    int projectId
  ) async {
    final idea = Idea(
      description: description,
      projectId: projectId
    );

    final repository = await ref.read(repositoryProvider.future);
    if (!ref.mounted) return;

    await repository.insertIdea(idea);
    
    ref.invalidate(projectIdeasNotifier);
  }
}

final ideaCreateNotifier =
AsyncNotifierProvider<IdeaCreateNotifier, void>(IdeaCreateNotifier.new);
