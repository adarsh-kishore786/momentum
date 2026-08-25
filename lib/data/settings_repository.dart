import 'dart:convert';

import 'package:momentum/models/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class SettingsRepository {
  Future<Settings> getSettings();
  Future<void> saveSettings(Settings settings);
}

class SettingsRepositoryException implements Exception {
  final String message;
  final Object? cause;

  SettingsRepositoryException(this.message, [this.cause]);

  @override
  String toString() =>
    'SettingsRepositoryException: $message${cause != null ? ' (cause: $cause)' : ''}';
}

class SharedPreferencesSettingsRepository implements SettingsRepository {
  final SharedPreferences _prefs;

  SharedPreferencesSettingsRepository(this._prefs);

  @override
  Future<Settings> getSettings() async {
    final raw = _prefs.getString(Settings.prefsKey);
    if (raw == null) return const Settings();

    final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(raw) as Map<String, dynamic>;
    } on FormatException catch (e) {
      throw SettingsRepositoryException(
        'Stored settings are not valid JSON', e
      );
    } on TypeError catch (e) {
      throw SettingsRepositoryException(
        'Stored settings are not a JSON object', e
      );
    }

    return Settings.fromJson(decoded);
  }

  @override
  Future<void> saveSettings(Settings settings) async {
    final encoded = jsonEncode(settings.toJson());
    final ok = await _prefs.setString(Settings.prefsKey, encoded);

    if (!ok) {
      throw SettingsRepositoryException(
        'SharedPreferences write failed'
      );
    }
  }
}
