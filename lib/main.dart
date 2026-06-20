import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/providers/providers.dart';
import 'package:momentum/screens/commons.dart';
import 'package:momentum/screens/dashboard_screen.dart';
import 'package:momentum/screens/history_screen.dart';
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
        repositoryProvider.overrideWithValue(FakeRepository())
      ],
      child: MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF141414),
          appBar: const MomentumHeader(),
          body: HistoryScreen(),
        ),
      )
    )
  );
}
