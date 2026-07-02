import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MomentumField extends StatelessWidget {
  const MomentumField({
    required this.controller,
    required this.label,
    this.autofocus = false,
    this.maxLines = 1,
    this.keyBoardType = TextInputType.text,
    this.errorText,
    super.key
  });

  final TextEditingController controller;
  final String label;
  final bool autofocus;
  final int maxLines;
  final String? errorText;
  final TextInputType keyBoardType;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      autofocus: autofocus,
      maxLines: maxLines,
      keyboardType: keyBoardType,
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

class MomentumDateSelector extends ConsumerStatefulWidget {
  final ValueChanged<DateTime> onDateSelected;
  final String? errorText;
  final DateTime? initialDate;

  const MomentumDateSelector({
    required this.onDateSelected,
    this.initialDate,
    this.errorText = '',
    super.key,
  });

  @override
  ConsumerState<MomentumDateSelector> createState() => _MomentumDateSelectorState();
}

class _MomentumDateSelectorState extends ConsumerState<MomentumDateSelector> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Initialize with a date if passed from the parent
    _selectedDate = widget.initialDate;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      // Send the selected date back up to the parent
      widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate == null
        ? 'Select Date'
        : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

    return ListTile(
      title: const Text('Date'),
      subtitle: Text(dateText),
      trailing: const Icon(Icons.calendar_today),
      onTap: () => _selectDate(context),
    );
  }
}

class SaveButton extends StatelessWidget {
  final String saveText;
  final bool saving;
  final Future<void> Function() save;

  const SaveButton({
    required this.saveText,
    required this.saving,
    required this.save,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: saving ? null : save,
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
          saving ? 'Saving…' : saveText,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.04,
          ),
        ),
      ),
    );
  }
}
