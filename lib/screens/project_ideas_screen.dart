import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/idea.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/notifiers/project_ideas_notifier.dart';
import 'package:momentum/screens/project_screen_commons.dart';

class ProjectIdeasScreen extends ConsumerWidget {
  
  final Project project;

  const ProjectIdeasScreen(this.project, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ideasState = ref.watch(projectIdeasNotifier(project.id!));

    return ideasState.when(  
      data: (ideas) => _IdeaList(ideas),
      error: (e, _) => ErrorBody(error: e),
      loading: () => LoadingBody()
    );
  }
}

class _IdeaList extends ConsumerWidget {
  final List<Idea> ideas;

  const _IdeaList(this.ideas);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EmptyState(message: 'Working on it...');
  }
}
