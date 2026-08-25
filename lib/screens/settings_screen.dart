import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:momentum/notifiers/settings_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        data: (settings) => _SettingsTable(
          themeMode: settings.themeMode,
          onThemeModeChanged: (mode) =>
              ref.read(settingsProvider.notifier).setThemeMode(mode),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _SettingsError(
          error: error,
          onRetry: () => ref.invalidate(settingsProvider),
        ),
      ),
    );
  }
}

class _SettingsTable extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const _SettingsTable({
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SettingsRow(
          label: 'Theme',
          child: SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto),
                label: Text('System'),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode),
                label: Text('Light'),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode),
                label: Text('Dark'),
              ),
            ],
            selected: {themeMode},
            // Single-select: onSelectionChanged always carries exactly
            // one value here, so `.first` is safe.
            onSelectionChanged: (selected) =>
                onThemeModeChanged(selected.first),
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _SettingsRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _SettingsError extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _SettingsError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 32),
            const SizedBox(height: 12),
            Text(
              'Couldn\'t load settings.\n$error',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
