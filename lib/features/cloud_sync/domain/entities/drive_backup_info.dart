class DriveBackupInfo {
  const DriveBackupInfo({
    required this.exportedAt,
    required this.sourceDeviceId,
    this.modifiedTime,
    this.fileSize,
  });

  final DateTime exportedAt;
  final String? sourceDeviceId;
  final DateTime? modifiedTime;
  final int? fileSize;
}
