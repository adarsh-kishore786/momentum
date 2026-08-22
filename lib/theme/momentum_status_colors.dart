import 'package:flutter/material.dart';

class MomentumStatusColors extends ThemeExtension<MomentumStatusColors> {
  final Color fresh, warm, stale;
  final Color plannedAccent, plannedFill, archivedFill;

  const MomentumStatusColors({
    required this.fresh,
    required this.warm,
    required this.stale,
    required this.plannedAccent,
    required this.plannedFill,
    required this.archivedFill,
  });

  @override
  MomentumStatusColors copyWith({
    Color? fresh, Color? warm, Color? stale,
    Color? plannedAccent, Color? plannedFill, Color? archivedFill,
  }) => MomentumStatusColors(
    fresh: fresh ?? this.fresh,
    warm: warm ?? this.warm,
    stale: stale ?? this.stale,
    plannedAccent: plannedAccent ?? this.plannedAccent,
    plannedFill: plannedFill ?? this.plannedFill,
    archivedFill: archivedFill ?? this.archivedFill,
  );

  @override
  MomentumStatusColors lerp(ThemeExtension<MomentumStatusColors>? other, double t) {
    if (other is! MomentumStatusColors) return this;
    return MomentumStatusColors(
      fresh: Color.lerp(fresh, other.fresh, t)!,
      warm: Color.lerp(warm, other.warm, t)!,
      stale: Color.lerp(stale, other.stale, t)!,
      plannedAccent: Color.lerp(plannedAccent, other.plannedAccent, t)!,
      plannedFill: Color.lerp(plannedFill, other.plannedFill, t)!,
      archivedFill: Color.lerp(archivedFill, other.archivedFill, t)!,
    );
  }
}
