# Privacy

## Philosophy

Financial data is sensitive. Spendly is designed so your data never leaves your device unless you explicitly choose to back it up. There is no Spendly account, no analytics SDK, and no server that receives your transactions.

---

## Local-Only Storage

All user data is stored in a SQLite file on the device. Nothing is transmitted automatically.

Data stored locally:

- Transactions (expenses and income)
- Categories and budgets
- Goals and contributions
- Lend and borrow records
- Settings and preferences
- Activity log

No data is sent to Spendly servers because there are none.

---

## Biometric Lock

When `privacyLockEnabled` is on, the app locks itself whenever it enters the background. Returning to the app requires authenticating with:

- Fingerprint
- Face recognition
- Device PIN (fallback)

### How It Works

`PrivacyLockGate` wraps the entire widget tree. It listens to `AppLifecycleState` changes:

```text
App goes to background (paused)
        ↓
PrivacyLockGate flags as locked
        ↓
App returns to foreground (resumed)
        ↓
local_auth.authenticate() called
        ↓
Success → show app content
Failure → keep lock screen visible
```

The biometric check is handled by the `local_auth` package. If biometrics are not enrolled, the device PIN is used as a fallback.

---

## Amount Visibility Toggle

Users can hide all financial figures in the UI with a single tap. Useful when:

- Sharing a screen
- Taking a screenshot
- Using the app in a public place

### How It Works

An `AmountVisibilityController` (a `ValueNotifier<bool>`) is created at the app root. Every widget that displays a money value reads from this notifier:

```text
User taps eye icon on home screen
        ↓
AmountVisibilityController.toggle()
        ↓
All amount widgets rebuild
        ↓
Numbers replaced with "••••"
```

The setting is also persisted in the `settings` table (`showAmountsEnabled`) so the preference survives app restarts.

---

## Cloud Backup (Optional)

Cloud sync is entirely opt-in. If you never connect a Google account, no data leaves the device.

When you do enable backup:

- Data is uploaded to **your own** Google Drive, in an app-private folder
- No Spendly server is involved in the transfer
- You can revoke Drive access at any time from Google Account settings
- Disconnecting your account in Spendly stops all future backups

See [backup.md](backup.md) for the full backup and restore flow.

---

## Data Ownership

You own your data. You can:

- Export everything as JSON from Settings
- Import a JSON backup to restore data
- Clear all data permanently from Settings

---

## Future Improvements

- Encrypted database file at rest (AES)
- Encrypted backup files on Google Drive
- Secure vault for sensitive notes and account details
- Export protection (password-protected JSON exports)