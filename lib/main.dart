import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/routing/router.dart';
import 'package:momentum/theme/momentum_status_colors.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    ProviderScope(
      child: const MomentumApp(),
    ),
  );
}

class MomentumApp extends ConsumerWidget {
  const MomentumApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Momentum',
      routerConfig: router,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF1C1C1C),
          surfaceDim: Color(0xFF181818),
          surfaceContainerHighest: Color(0xFF141414),
          // replaces hardcoded field fill onSurface: Color(0xFFE8E8E8),
          onSurfaceVariant: Color(0xFF888888),
          outline: Color(0xFF2A2A2A),
          // real dividers/borders outlineVariant: Color(0xFF1E1E1E),
          primary: Color(0xFFC8F53A),
          onPrimary: Color(0xFF0F0F0F),
          secondary: Color(0xFF555555),
          // muted UI text, not a fill color error: Color(0xFFE84C3D),
          // reserved for real errors only onError: Colors.white,
        ),
        extensions: const[
          MomentumStatusColors(
            fresh: Color(0xFFC8F53A),
            warm: Color(0xFFF5C23A),
            stale: Color(0xFFF5603A),
            plannedAccent: Color(0xFF3AB8F5),
            plannedFill: Color(0xFF17232B),
            archivedFill: Color(0xFF1A1A1A),
          )
        ],
      )
    );
  }
}
