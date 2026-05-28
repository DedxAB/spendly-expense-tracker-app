class CloudSyncState {
  const CloudSyncState({
    required this.isConnected,
    this.connectedEmail,
    required this.automaticDailyBackup,
    this.lastBackupAt,
    this.isProcessing = false,
  });

  final bool isConnected;
  final String? connectedEmail;
  final bool automaticDailyBackup;
  final DateTime? lastBackupAt;
  final bool isProcessing;

  CloudSyncState copyWith({
    bool? isConnected,
    String? connectedEmail,
    bool clearConnectedEmail = false,
    bool? automaticDailyBackup,
    DateTime? lastBackupAt,
    bool clearLastBackupAt = false,
    bool? isProcessing,
  }) {
    return CloudSyncState(
      isConnected: isConnected ?? this.isConnected,
      connectedEmail: clearConnectedEmail
          ? null
          : (connectedEmail ?? this.connectedEmail),
      automaticDailyBackup: automaticDailyBackup ?? this.automaticDailyBackup,
      lastBackupAt: clearLastBackupAt
          ? null
          : (lastBackupAt ?? this.lastBackupAt),
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}
