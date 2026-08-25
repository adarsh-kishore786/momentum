import 'package:flutter/material.dart';

class Settings {
  static const String prefsKey = 'settings';

  final ThemeMode themeMode;

  const Settings({
    this.themeMode = ThemeMode.system
  });

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name
    };
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == json['themeMode'],
        orElse: () => ThemeMode.system
      )
    );
  }

  Settings copyWith({ThemeMode? themeMode}) {
    return Settings(themeMode: themeMode ?? this.themeMode);
  }
}
