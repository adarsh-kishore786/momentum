import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/notifiers/dashboard_notifier.dart';
import 'package:momentum/screens/commons.dart';

class AddProject extends ConsumerStatefulWidget {
  const AddProject({super.key});

  @override
  ConsumerState<AddProject> createState() => _AddProject();
}

class _AddProject extends ConsumerState<AddProject> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _saving = false;
  String? _nameError;
  String? _saveError;

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
      await ref.read(dashboardProvider.notifier).insertProject(name, desc);

      if (mounted) Navigator.of(context).pop();
      return true;
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveError = 'Failed to save project. Try again.';
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
      padding: EdgeInsets.fromLTRB(
        24, 24, 24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // drag handle
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
            'New project',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 20),

          MomentumField(
            controller: _nameController,
            label: 'Name',
            autofocus: true,
            errorText: _nameError,
          ),
          const SizedBox(height: 12),
          MomentumField(
            controller: _descController,
            label: 'Description',
            maxLines: 3,
          ),

          const SizedBox(height: 24),

          SaveButton(
            saveText: 'Save project',
            saving: _saving,
            save: _save,
            successMessage: "Project saved in planned section",
          ),

          if (_saveError != null) ...[
            const SizedBox(height: 12),
            Text(
              _saveError!,
              style: TextStyle(fontSize: 13, color: cs.error),
            ),
          ],
        ],
      ),
    );
  }
}
