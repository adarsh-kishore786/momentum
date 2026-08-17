import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/session.dart';
import 'package:momentum/notifiers/session_create_notifier.dart';
import 'package:momentum/notifiers/session_notifier.dart';
import 'package:momentum/screens/commons.dart';

class SessionForm extends ConsumerStatefulWidget {
  final Project project;
  final Session? session; // null = log new, non-null = edit existing

  const SessionForm({required this.project, this.session, super.key});

  @override
  ConsumerState<SessionForm> createState() => _SessionFormState();
}

class _SessionFormState extends ConsumerState<SessionForm> {
  late final TextEditingController _durationController;
  late final TextEditingController _notesController;
  late DateTime _selectedDate;

  bool _saving = false;
  String? _durationError;
  String? _notesError;
  String? _saveError;

  bool get _isEditing => widget.session != null;

  @override
  void initState() {
    super.initState();
    _durationController = TextEditingController(
      text: widget.session != null ? widget.session!.durationMinutes.toString() : '',
    );
    _notesController = TextEditingController(text: widget.session?.note ?? '');
    _selectedDate = widget.session?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<bool> _save() async {
    final int? duration = int.tryParse(_durationController.text.trim());
    final notes = _notesController.text.trim();

    if (duration == null || duration <= 0) {
      setState(() => _durationError = 'Duration must be valid');
      return false;
    }
    if (notes.isEmpty) {
      setState(() => _notesError = 'Notes cannot be empty');
      return false;
    }

    setState(() {
      _saving = true;
      _durationError = null;
      _notesError = null;
      _saveError = null;
    });

    try {
      if (_isEditing) {
        final notifier = ref.read(sessionProvider(widget.session!.id!).notifier);
        await notifier.updateSession(
          widget.session!.copyWith(
            durationMinutes: duration,
            note: notes,
            date: _selectedDate.toUtc(),
          ),
        );
      } else {
        final notifier = ref.read(sessionCreateProvider.notifier);
        await notifier.logSession(
          duration,
          notes,
          _selectedDate.toUtc(),
          widget.project.id!,
        );
      }
      if (mounted) Navigator.of(context).pop();
      return true;
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveError = _isEditing
              ? 'Failed to update session.\nTry again.'
              : 'Failed to log session.\nTry again.';
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
            _isEditing ? 'Edit session for ${widget.project.name}' : 'Log session for ${widget.project.name}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: cs.onSurface),
          ),
          const SizedBox(height: 20),
          MomentumField(
            controller: _durationController,
            label: 'Duration (min)',
            autofocus: true,
            keyBoardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
            errorText: _durationError,
          ),
          const SizedBox(height: 20),
          MomentumField(
            controller: _notesController,
            label: 'Notes',
            maxLines: 2,
            errorText: _notesError,
          ),
          MomentumDateSelector(
            initialDate: _selectedDate,
            onDateSelected: (newDate) => setState(() => _selectedDate = newDate),
          ),
          const SizedBox(height: 24),
          SaveButton(
            saveText: _isEditing ? 'Save changes' : 'Log session',
            saving: _saving,
            save: _save,
            successMessage: _isEditing ? 'Session updated' : 'Session logged!',
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
