# Backup

## Overview

Spendly backs up your data to Google Drive so you can restore it if you switch devices or reinstall the app. The local SQLite database is always the source of truth. Drive is a portable snapshot for recovery and device migration, not a live sync engine.

---

## How It Works

Backup is a two-step process: export the local database to JSON, then upload that file to Google Drive.

### Backup Flow

```text
User triggers backup (manually or on app launch)
        |
CloudSyncRepository.backupNow()
        |
SettingsRepository.exportJson()
  <- reads all tables: transactions, categories, settings,
     recurring rules, goals, lend entries, activity logs,
     and app usage totals
        |
DriveService.uploadFile(jsonString)
  <- authenticates with the connected Google account
  <- uploads file to the app's private Drive folder
        |
Backup metadata saved (timestamp, file ID)
```

### Restore Flow

```text
User taps "Restore from Backup"
        |
CloudSyncRepository.restoreFromDrive()
        |
DriveService.downloadLatestFile()
  <- fetches the JSON file from Drive
        |
SettingsRepository.importJson(jsonString)
  <- clears existing local data
  <- writes all records back to SQLite
        |
App reloads - streams emit fresh data
```

---

## Google Account Integration

Handled by two services:

- `GoogleAuthService` - wraps `google_sign_in`. Provides `connectAccount()` and `disconnectAccount()`. Stores the signed-in account state.
- `DriveService` - wraps the Google Drive REST API. Creates a dedicated app folder, uploads/downloads the backup JSON file.

### Connect Account Flow

```text
User taps "Connect Google Account"
        |
GoogleAuthService.connectAccount()
  <- opens Google Sign-In sheet
  <- returns authenticated account (email, token)
        |
CloudSyncState updates to "connected"
        |
Settings page shows connected email and backup options
```

### Disconnect Flow

```text
User taps "Disconnect"
        |
GoogleAuthService.disconnectAccount()
  <- signs out and revokes Drive access
        |
CloudSyncState updates to "disconnected"
```

---

## Automatic Daily Backup

On every app launch, `SplashPage` calls `CloudSyncRepository.runDailyBackupIfNeeded()`.

```text
App launches -> SplashPage
        |
runDailyBackupIfNeeded()
  <- checks: is a Google account connected?
  <- checks: has a backup already run today?
  <- if yes to both -> skip
  <- if no -> run backupNow()
```

This means the user's last day of data is always protected without any manual action.

---

## What Gets Backed Up

The JSON export includes all user data:

- Transactions (including recurring instances)
- Categories (including custom ones)
- Recurring rules
- Settings (budget, currency, preferences)
- Goals and contributions
- Lend entries and settlements
- Monthly reflections
- Category budgets
- Activity events
- App usage days and lifetime screen-time totals

---

## What Does Not Get Backed Up

- Notification state (managed by the OS)

App usage is recorded locally on each device, but because it is included in the backup snapshot, it can be restored onto another device when you import the Drive backup.

---

## Security

- Backup is stored in the user's own Google Drive, in an app-private folder
- No Spendly server ever sees your financial data
- Drive access can be revoked at any time from Google Account settings

---

## Future Enhancements

- Encrypted backup file (AES)
- Backup history with restore-to-specific-date
- One-tap restore with conflict resolution
- Automatic backup on significant data changes
