import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/providers/providers.dart';
import 'package:momentum/routing/router.dart';
import 'package:momentum/test/fake_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(FakeRepository()),
      ],
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
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF141414),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF141414),
          primary: Color(0xFFC8F53A),
        ),
      ),
      routerConfig: router,
    );
  }
}
