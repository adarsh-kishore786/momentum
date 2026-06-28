import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/notifiers/project_notifier.dart';

class ProjectScreen extends ConsumerWidget {
  final int projectId;

  const ProjectScreen({required this.projectId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectNotifier(projectId));

    return SafeArea(
      child: state.when(
        data: (project) => _ProjectScreen(project: project),
        error: (e, _) => Center(
          child: Text("Error: $e", style: const TextStyle(color: Colors.red)),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator()
        )
      ),
    );
  }
}

class _ProjectScreen extends StatelessWidget {
  final Project project;

  const _ProjectScreen({required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          project.name,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary
          ),
        ),
      ),
    );
  }
}
