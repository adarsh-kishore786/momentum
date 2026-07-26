import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/notifiers/backup_notifier.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  @override
    Widget build(BuildContext context, WidgetRef ref) {
      final state = ref.watch(backupNotifierProvider);
      final busy = state.status == BackupStatus.working;

      return Scaffold(
          appBar: AppBar(title: const Text('Backup and Restore')),
          body: ListView(
            children: [
            ListTile(
              title: const Text('Export as SQLite DB'),
              trailing: busy ? const CircularProgressIndicator() : null,
              enabled: !busy,
              onTap: () async {
              final file = await ref.read(backupNotifierProvider.notifier).export();
              if (!context.mounted) return;

              if (file == null) {
              _showError(context, ref);
              return;
              }

              final bytes = await file.readAsBytes();
              final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');

              final savedPath = await FilePicker.platform.saveFile(
                  dialogTitle: 'Save Momentum backup',
                  fileName: 'momentum_backup_$timestamp.mbak',
                  bytes: bytes, // required on Android/iOS; ignored on desktop
                  type: FileType.custom,
                  allowedExtensions: ['mbak'],
                  );

              if (!context.mounted) return;

              if (savedPath == null) {
                // user cancelled — not an error, don't show a snackbar
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup saved')),
                  );
              },
              ),
              ListTile(
                  title: const Text('Import from SQLite DB'),
                  subtitle: const Text('This replaces all current data'),
                  enabled: !busy,
                  onTap: () async {
                  final confirmed = await _confirmImport(context);
                  if (!confirmed) return;

                  FilePickerResult? result;
                  try {
                    result = await FilePicker.platform.pickFiles(
                      type: FileType.any,
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Could not open file picker: $e"))
                    );
                  }

                  final path = result?.files.single.path;
                  if (path == null) return;

                  final ok = await ref.read(backupNotifierProvider.notifier).import(path);
                  if (!ok && context.mounted) {
                  _showError(context, ref);
                  } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Import successful')),
                      );
                  }
                  },
                  ),
                  ],
                  ),
                  );
    }

  Future<bool> _confirmImport(BuildContext context) async {
    return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Replace all data?'),
          content: const Text(
            'Importing a backup will permanently replace all projects and sessions currently on this device.',
            ),
          actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Replace')),
          ],
          ),
        ) ?? false;
  }

  void _showError(BuildContext context, WidgetRef ref) {
    final message = ref.read(backupNotifierProvider).message ?? 'Something went wrong';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
