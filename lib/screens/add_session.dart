import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/screens/commons.dart';

class AddSession extends ConsumerStatefulWidget {
  final Project project;

  const AddSession({required this.project, super.key});

  @override
  ConsumerState<AddSession> createState() => 
    _AddSession();
}

class _AddSession extends ConsumerState<AddSession> {
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;

  bool _saving = false;
  String? _durationError;
  String? _notesError;
  String? _saveError;

  @override
  void dispose() {
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final int? duration = int.tryParse(_durationController.text.trim());
    final notes = _notesController.text.trim();

    if (duration == 0 || duration == null) {
      setState(() => _durationError = 'Duration must be valid');
      return;
    }

    if (notes.isEmpty) {
      setState(() => _notesError = 'Notes cannot be empty');
      return;
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
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            )
          ),

          Text(
            'Log session',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: cs.onSurface
            ),
          ),

          const SizedBox(height: 20),

          MomentumField(
            controller: _durationController,
            label: 'Duration (min)',
            autofocus: true,
            keyBoardType: TextInputType.numberWithOptions(decimal: false, signed: false),
            errorText: _durationError,
          ),

          const SizedBox(height: 20),

          MomentumField(
            controller: _notesController,
            label: 'Notes',
            errorText: _notesError,
          ),

          MomentumDateSelector(
            initialDate: DateTime.now(),
            onDateSelected: (newDate) {
              setState(() {
                _selectedDate = newDate;
              });
            },
          ),

          const SizedBox(height: 24),

          SaveButton(
            type: 'session',
            saving: _saving,
            save: _save,
          )
        ],
      ),
    );
  }
}
