import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/data/settings_repository.dart';
import 'package:momentum/models/settings.dart';
import 'package:momentum/providers/providers.dart';

class SettingsNotifier extends AsyncNotifier<Settings> {
  @override
  FutureOr<Settings> build() async {
    try {
      return await ref.watch(settingsRepositoryProvider).getSettings();
    } on SettingsRepositoryException {
      return const Settings();
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final current = state.value ?? const Settings();
    if (current.themeMode == themeMode) return;

    final updated = current.copyWith(themeMode: themeMode);

    state = await AsyncValue.guard(() async {
      await ref.read(settingsRepositoryProvider).saveSettings(updated);
      return updated;
    });
  }
}

final settingsProvider = 
  AsyncNotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);
