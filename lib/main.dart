import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/data/repository/fake_project_repository.dart';
import 'package:momentum/providers/providers.dart';
import 'package:momentum/screens/dashboard_screen.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        projectRepositoryProvider.overrideWithValue(FakeProjectRepository())
      ],
      child: MaterialApp(
        home: DashboardScreen()
      )
    )
  );
}
