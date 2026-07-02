import 'package:flutter/material.dart';

class MomentumField extends StatelessWidget {
  const MomentumField({
    required this.controller,
    required this.label,
    this.autofocus = false,
    this.maxLines = 1,
    this.errorText,
    super.key
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
