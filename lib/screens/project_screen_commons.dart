import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/project_status.dart';
import 'package:momentum/notifiers/project_notifier.dart';
import 'package:momentum/screens/commons.dart';
import 'package:momentum/screens/project_form.dart';

class LoadingBody extends StatelessWidget {
  const LoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        DetailAppBar(project: null),
        SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}

class ErrorBody extends StatelessWidget {
  const ErrorBody({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CustomScrollView(
      slivers: [
        const DetailAppBar(project: null),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Failed to load project details. Try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.error, fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DetailAppBar extends ConsumerWidget {
  const DetailAppBar({required this.project, super.key});

  final Project? project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return SliverAppBar(
      pinned: true,
      forceElevated: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: cs.onSurfaceVariant,
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          color: cs.primary,
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => ProjectForm(project: project),
          ),
        ),
        if (project != null && project!.status != ProjectStatus.archived)
          IconButton(
            icon: const Icon(Icons.archive),
            color: cs.onSurface,
            onPressed: () async {
              await ref.read(projectProvider(project!.id!).notifier).archive();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Project archived.')));

              Navigator.of(context).pop();
            },
          ),
        if (project != null && project!.status == ProjectStatus.archived)
          IconButton(
            icon: const Icon(Icons.unarchive),
            color: cs.onSurface,
            onPressed: () async {
              await ref.read(projectProvider(project!.id!).notifier).unarchive();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Project unarchived.')));

              Navigator.of(context).pop();
            },
          ),
        IconButton(
          icon: const Icon(Icons.delete),
          color: cs.error,
          onPressed: project == null
              ? null
              : () async {
                  final bool? confirm = await confirmDelete(context);

                  if (confirm == true) {
                    await ref.read(projectProvider(project!.id!).notifier).deleteProject();

                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Project deleted')));
                  }
                },
        ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: cs.onSurfaceVariant.withValues(alpha: 0.4),
            height: 1.6,
          ),
        ),
      ),
    );
  }
}
