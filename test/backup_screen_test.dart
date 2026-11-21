import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/data/backup_exception.dart';
import 'package:momentum/data/backup_repository.dart';
import 'package:momentum/notifiers/backup_notifier.dart';
import 'package:momentum/screens/backup_screen.dart';

/// A repository fake that returns a real temp file, so the screen's
/// `readAsBytes()` / `copy()` calls behave like production code.
class _FakeBackupRepository implements BackupRepository {
  _FakeBackupRepository(this._exportFile, [this._exportError]);

  final File _exportFile;
  final BackupException? _exportError;

  @override
  Future<File> prepareExport() async {
    final error = _exportError;
    if (error != null) throw error;
    return _exportFile;
  }

  @override
  Future<void> importFrom(String sourcePath) async {}
}

/// Replaces the static `FilePicker.platform` so no real save dialog opens.
class _FakeFilePicker extends FilePicker {
  _FakeFilePicker(this._result);

  final String? Function() _result;
  int saveFileCalls = 0;

  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async {
    saveFileCalls++;
    return _result();
  }
}

void main() {
  late Directory tempDir;
  late File exportFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('momentum_backup_test_');
    exportFile = File('${tempDir.path}/source.mbak');
    await exportFile.writeAsBytes(const [1, 2, 3]);
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  /// The screen's onTap alternates between real async work (dart:io) and
  /// continuations in the fake-async zone. runAsync lets the former finish;
  /// pump flushes the latter. Interleave the two so neither side waits on the
  /// other — waiting inside runAsync for a fake-zone signal would deadlock.
  Future<void> settleRealAsync(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
  }

  Future<void> pumpScreen(WidgetTester tester, BackupRepository repo) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [backupRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: BackupScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'cancelling the save picker does not show "Backup saved"',
    (tester) async {
      final picker = _FakeFilePicker(() => null);
      FilePicker.platform = picker;
      final repo = _FakeBackupRepository(exportFile);

      await pumpScreen(tester, repo);
      await tester.tap(find.text('Export as SQLite DB'));
      await settleRealAsync(tester);

      expect(picker.saveFileCalls, 1);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('Backup saved'), findsNothing);
    },
  );

  testWidgets(
    'a completed save shows "Backup saved" and writes the destination',
    (tester) async {
      final destination = '${tempDir.path}/saved.mbak';
      final picker = _FakeFilePicker(() => destination);
      FilePicker.platform = picker;
      final repo = _FakeBackupRepository(exportFile);

      await pumpScreen(tester, repo);
      await tester.tap(find.text('Export as SQLite DB'));
      await settleRealAsync(tester);

      expect(picker.saveFileCalls, 1);
      expect(find.text('Backup saved'), findsOneWidget);
      expect(File(destination).existsSync(), isTrue);
      expect(File(destination).readAsBytesSync(), [1, 2, 3]);
      // The desktop path copies then removes the temp export file.
      expect(exportFile.existsSync(), isFalse);
    },
  );

  testWidgets(
    'a failed export shows the error and never opens the picker',
    (tester) async {
      final picker = _FakeFilePicker(() => null);
      FilePicker.platform = picker;
      final repo = _FakeBackupRepository(
        exportFile,
        const BackupIOException('export blew up'),
      );

      await pumpScreen(tester, repo);
      await tester.tap(find.text('Export as SQLite DB'));
      await settleRealAsync(tester);

      expect(picker.saveFileCalls, 0);
      expect(find.text('export blew up'), findsOneWidget);
      expect(find.text('Backup saved'), findsNothing);
    },
  );
}
