sealed class BackupException implements Exception {
  final String message;
  const BackupException(this.message);
}

class InvalidBackupFileException extends BackupException {
  const InvalidBackupFileException()
      : super('Selected file is not a valid Momentum backup.');
}

class BackupIOException extends BackupException {
  const BackupIOException(super.message);
}
