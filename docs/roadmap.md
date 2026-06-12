# Roadmap

## Shipped

Everything listed here is fully implemented in the codebase.

### Core

- Offline-first architecture (Drift + SQLite, no server required)
- Expense and income tracking
- Custom categories with icon and color
- Payment mode tracking (cash, card, UPI)
- Soft delete with restore support

### Budget

- Monthly budget with remaining balance on dashboard
- Per-category monthly budgets
- Budget alert notifications when spending is close to limit

### Recurring Transactions

- Recurring rules with daily / weekly / monthly / yearly frequency
- Auto-generation of transaction instances on app launch
- Pause, resume, and delete rules
- "Delete this and future" to stop a rule from a date

### Analytics

- Expense trend chart (daily and monthly)
- Expense distribution by category (pie chart)
- Income vs expense comparison
- Yearly income vs expense (monthly bars)
- Payment mode breakdown

### Goals

- Financial goals with target amount and monthly contribution
- Emergency fund (dedicated goal type)
- Contribution history per goal
- Progress tracking (% complete, months to reach target)

### Lending

- Track money lent to and borrowed from people
- Partial settlement support
- Per-person balance summary

### Privacy & Security

- Biometric lock (fingerprint / face / PIN) on app resume
- Hide all financial amounts with a single toggle
- All data stored locally on device

### Notifications

- Daily reminder notification
- Budget alert when spending approaches the monthly limit

### Cloud Sync

- Google account sign-in
- Automatic daily backup to Google Drive
- Manual backup and restore

### Settings

- Currency setting
- Monthly budget configuration
- Notification preferences
- Data export and import (JSON)
- Clear all data

### Onboarding

- Profile setup on first launch
- Routes directly to home on subsequent launches

---

## In Progress

- Improved backup UX (backup status, last backup time)
- Richer monthly analytics and spending comparisons
- Monthly reflections (notes per month)

---

## Planned

### Smart Search

Natural language search across transactions:

- "Food expenses this month"
- "Swiggy spending"
- "Coffee last week"

---

### CSV Import & Export

Import transactions from:

- Bank statements
- Excel / CSV files
- Other finance apps

---

### Financial Insights (AI-assisted)

- Spending trend analysis with recommendations
- Monthly budget recommendations based on history
- Unusual spending alerts

---

### Multi-Currency Support

Track transactions in different currencies with conversion.

---

### Encrypted Backups

AES-encrypted Drive backup files. Data is unreadable even if the Drive account is compromised.

---

### Secure Vault

Store sensitive non-transaction data:

- Account numbers
- Card details
- Important IDs

---

### Backup History

- View list of past backups
- Restore to a specific date

---

## Long-Term Vision

A privacy-first personal finance app that works completely offline, gives users full ownership of their data, and uses smart insights to help them make better financial decisions — without sending any data to a third-party server.