import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/notifiers/dashboard_notifier.dart';
import 'package:momentum/screens/commons.dart';

class ProjectForm extends ConsumerStatefulWidget {
  final Project? project; // null = create, non-null = edit

  const ProjectForm({super.key, this.project});

  @override
  ConsumerState<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends ConsumerState<ProjectForm> {
  late final _nameController = TextEditingController(text: widget.project?.name ?? '');
  late final _descController = TextEditingController(text: widget.project?.description ?? '');
  bool _saving = false;
  String? _nameError;
  String? _saveError;

  bool get _isEditing => widget.project != null;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<bool> _save() async {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();

    if (name.isEmpty) {
      setState(() => _nameError = 'Name is required');
      return false;
    }

    setState(() {
      _saving = true;
      _nameError = null;
      _saveError = null;
    });

    try {
      final notifier = ref.read(dashboardProvider.notifier);
      if (_isEditing) {
        await notifier.updateProject(
          widget.project!.copyWith(name: name, description: desc),
        );
      } else {
        await notifier.insertProject(name, desc);
      }

      if (mounted) Navigator.of(context).pop();
      return true;
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveError = _isEditing
              ? 'Failed to update project. Try again.'
              : 'Failed to save project. Try again.';
        });
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            _isEditing ? 'Edit project' : 'New project',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: cs.onSurface),
          ),
          const SizedBox(height: 20),
          MomentumField(
            controller: _nameController,
            label: 'Name',
            autofocus: true,
            errorText: _nameError
          ),
          const SizedBox(height: 12),
          MomentumField(
            controller: _descController,
            label: 'Description',
            maxLines: 3
          ),
          const SizedBox(height: 24),
          SaveButton(
            saveText: _isEditing ? 'Save changes' : 'Save project',
            saving: _saving,
            save: _save,
            successMessage: _isEditing ? 'Project updated' : 'Project saved',
          ),
          if (_saveError != null) ...[
            const SizedBox(height: 12),
            Text(_saveError!, style: TextStyle(fontSize: 13, color: cs.error)),
          ],
        ],
      ),
    );
  }
}
