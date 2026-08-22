import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/idea.dart';
import 'package:momentum/notifiers/project_ideas_notifier.dart';
import 'package:momentum/providers/providers.dart';

class IdeaNotifier extends AsyncNotifier<void> {
  final int ideaId;

  IdeaNotifier(this.ideaId);

  @override
  FutureOr<void> build() {}

  Future<void> updateIdea(Idea idea) async {
    final repository = await ref.read(repositoryProvider.future);
    if (!ref.mounted) return;

    await repository.updateIdea(idea);
    if (!ref.mounted) return;

    ref.invalidate(projectIdeasNotifier);
  }

  Future<void> delete() async {
    final repository = await ref.read(repositoryProvider.future);
    if (!ref.mounted) return;

    await repository.deleteIdea(ideaId);

    ref.invalidate(projectIdeasNotifier);
  }
}

final ideaProvider = AsyncNotifierProvider.family<IdeaNotifier, void, int>(IdeaNotifier.new);
