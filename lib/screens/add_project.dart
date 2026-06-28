import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/notifiers/dashboard_notifier.dart';

class AddProjectSheet extends ConsumerStatefulWidget {
  const AddProjectSheet({super.key});

  @override
  ConsumerState<AddProjectSheet> createState() => _AddProjectSheetState();
}

class _AddProjectSheetState extends ConsumerState<AddProjectSheet> {
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

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();

    if (name.isEmpty) {
      setState(() => _nameError = 'Name is required');
      return;
    }

    setState(() {
      _saving = true;
      _nameError = null;
      _saveError = null;
    });

    try {
      await ref.read(dashboardProvider.notifier).insertProject(name, desc);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveError = 'Failed to save project. Try again.';
        });
      }
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

          _MomentumField(
            controller: _nameController,
            label: 'Name',
            autofocus: true,
            errorText: _nameError,
          ),
          const SizedBox(height: 12),
          _MomentumField(
            controller: _descController,
            label: 'Description',
            maxLines: 3,
          ),

          if (_saveError != null) ...[
            const SizedBox(height: 12),
            Text(
              _saveError!,
              style: TextStyle(fontSize: 13, color: cs.error),
            ),
          ],

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: const Color(0xFF0F0F0F),
                disabledBackgroundColor: cs.primary.withValues(alpha: 0.4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                _saving ? 'Saving…' : 'Save project',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.04,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MomentumField extends StatelessWidget {
  const _MomentumField({
    required this.controller,
    required this.label,
    this.autofocus = false,
    this.maxLines = 1,
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final bool autofocus;
  final int maxLines;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      autofocus: autofocus,
      maxLines: maxLines,
      style: TextStyle(fontSize: 14, color: cs.onSurface),
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
        filled: true,
        fillColor: const Color(0xFF141414),
        errorStyle: TextStyle(color: cs.error),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF252525)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error),
        ),
      ),
    );
  }
}
