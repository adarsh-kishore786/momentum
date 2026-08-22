import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/idea.dart';
import 'package:momentum/models/idea_state.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/notifiers/idea_create_notifier.dart';
import 'package:momentum/notifiers/idea_notifier.dart';
import 'package:momentum/notifiers/project_ideas_notifier.dart';
import 'package:momentum/screens/commons.dart';
import 'package:momentum/screens/project_screen_commons.dart';

class ProjectIdeasScreen extends ConsumerWidget {
  final Project project;

  const ProjectIdeasScreen(this.project, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ideasState = ref.watch(projectIdeasNotifier(project.id!));

    return ideasState.when(
      data: (ideas) => _IdeaList(project: project, ideas: ideas),
      error: (e, _) => ErrorBody(error: e),
      loading: () => LoadingBody(),
    );
  }
}

class _IdeaList extends ConsumerWidget {
  final Project project;
  final List<Idea> ideas;

  const _IdeaList({required this.project, required this.ideas});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    if (ideas.isEmpty) {
      return Column(
        children: [
          const Expanded(child: EmptyState(message: 'No ideas yet.')),
          AddIdeaField(projectId: project.id!),
        ],
      );
    }

    final open = ideas.where((i) => i.state == IdeaState.open).toList();
    final done = ideas.where((i) => i.state == IdeaState.done).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${ideas.length} ideas · ${done.length} done',
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 10,
                letterSpacing: 1.2,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: open.length + done.length,
            separatorBuilder: (_, _) =>
                Divider(height: 1, color: cs.surfaceDim),
            itemBuilder: (context, index) {
              final idea =
                  index < open.length ? open[index] : done[index - open.length];
              return _IdeaTile(idea: idea);
            },
          ),
        ),
        AddIdeaField(projectId: project.id!),
      ],
    );
  }
}

class _IdeaTile extends ConsumerWidget {
  final Idea idea;

  const _IdeaTile({required this.idea});

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _EditIdeaDialog(initialText: idea.description),
    );

    if (result == null || result == idea.description || !context.mounted) return;

    try {
      await ref
          .read(ideaProvider(idea.id!).notifier)
          .updateIdea(idea.copyWith(description: result));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t save idea: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final ideaState = ref.watch(ideaProvider(idea.id!));
    final isBusy = ideaState.isLoading;
    final isDone = idea.state == IdeaState.done;

    ref.listen(ideaProvider(idea.id!), (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Couldn\'t update idea: ${next.error}')),
        );
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: isBusy
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.primary,
                    ),
                  )
                : InkWell(
                    onTap: () => ref
                        .read(ideaProvider(idea.id!).notifier)
                        .updateIdea(idea.copyWith(
                          state: isDone ? IdeaState.open : IdeaState.done,
                        )),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: isDone
                            ? cs.primary.withValues(alpha: 0.18)
                            : null,
                        border: Border.all(
                          color: isDone
                              ? cs.primary.withValues(alpha: 0.6)
                              : cs.outline,
                          width: 1.5,
                        ),
                      ),
                      child: isDone
                          ? Icon(Icons.check, size: 12, color: cs.primary)
                          : null,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              idea.description,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: isDone
                    ? cs.onSurfaceVariant.withValues(alpha: 0.4)
                    : cs.onSurface,
                decoration:
                    isDone ? TextDecoration.lineThrough : TextDecoration.none,
                decorationColor: cs.outline,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            color: cs.onSurface,
            onPressed: isBusy ? null : () => _showEditDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 18),
            color: cs.error,
            onPressed: isBusy
                ? null
                : () async {
                    final confirm = await confirmDelete(context, item: 'idea');
                    if (confirm != true) return;

                    await ref.read(ideaProvider(idea.id!).notifier).delete();

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Idea deleted')));
                  },
          ),
        ],
      ),
    );
  }
}

/// Owns its own TextEditingController so disposal is tied to this State's
/// lifecycle rather than to the timing of the await in the caller — avoids
/// disposing while the dialog's exit transition is still animating.
class _EditIdeaDialog extends StatefulWidget {
  final String initialText;

  const _EditIdeaDialog({required this.initialText});

  @override
  State<_EditIdeaDialog> createState() => _EditIdeaDialogState();
}

class _EditIdeaDialogState extends State<_EditIdeaDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit idea'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 3,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isEmpty) return;
            Navigator.pop(context, text);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class AddIdeaField extends ConsumerStatefulWidget {
  final int projectId;

  const AddIdeaField({required this.projectId, super.key});

  @override
  ConsumerState<AddIdeaField> createState() => _AddIdeaFieldState();
}

class _AddIdeaFieldState extends ConsumerState<AddIdeaField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    try {
      await ref
          .read(ideaCreateNotifier.notifier)
          .insertIdea(text, widget.projectId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t add idea: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final createState = ref.watch(ideaCreateNotifier);
    final isSubmitting = createState.isLoading;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
      child: SingleChildScrollView(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !isSubmitting,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: 'Add an idea…',
                  hintStyle: TextStyle(color: cs.onSurfaceVariant),
                  filled: true,
                  fillColor: cs.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: cs.surfaceDim),
                  ),
                ),
                style: TextStyle(fontSize: 13, color: cs.onSurface),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: isSubmitting ? null : _submit,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primary,
                ),
                child: isSubmitting
                    ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.onPrimary,
                        ),
                      )
                    : Icon(Icons.add, color: cs.onPrimary, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
