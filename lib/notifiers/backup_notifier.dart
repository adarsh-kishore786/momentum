import 'dart:io';

import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/data/backup_exception.dart';
import 'package:momentum/data/backup_repository.dart';
import 'package:momentum/providers/providers.dart';

enum BackupStatus { idle, working, success, error }

class BackupState {
  final BackupStatus status;
  final String? message;
  const BackupState(this.status, [this.message]);
}

class BackupNotifier extends Notifier<BackupState> {
  @override
  BackupState build() => const BackupState(BackupStatus.idle);

  Future<File?> export() async {
    state = const BackupState(BackupStatus.working);
    try {
      final file = await ref.read(backupRepositoryProvider).prepareExport();
      state = const BackupState(BackupStatus.success);
      return file;
    } on BackupException catch (e) {
      state = BackupState(BackupStatus.error, e.message);
      return null;
    }
  }

  Future<bool> import(String path) async {
    state = const BackupState(BackupStatus.working);
    try {
      await ref.read(backupRepositoryProvider).importFrom(path);
      state = const BackupState(BackupStatus.success);
      SchedulerBinding.instance.addPostFrameCallback((_)
        {
          ref.invalidate(databaseProvider);
        }
      );
      return true;
    } on BackupException catch (e) {
      state = BackupState(BackupStatus.error, e.message);
      return false;
    }
  }
}

final backupNotifierProvider =
    NotifierProvider<BackupNotifier, BackupState>(BackupNotifier.new);

final backupRepositoryProvider = Provider<BackupRepository>(
  (ref) => SqfliteBackupRepository(),
);
