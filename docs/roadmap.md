# Roadmap

## Shipped

Everything listed here is fully implemented in the codebase.

### Core

- Offline-first architecture (Drift + SQLite, no server required)
- Expense, income, and investment tracking
- Custom categories with icon and color
- Payment mode tracking (cash, card, UPI)
- Soft delete with restore support
- Full-text search across transactions
- Sort by date or amount

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

- Expense trend line chart (daily and monthly)
- Expense distribution by category (ranked list)
- Income vs expense comparison (bar chart)
- Yearly income vs expense (monthly bars)
- Payment mode breakdown (in PDF export)
- Burn rate card with projected monthly expense
- "What's Changed" natural-language spending insights
- Trend snapshot (active periods, peak spending)
- Month-over-month spending change percentage
- Budget progress bar with remaining/over indicator
- PDF export of full analytics report

### Goals

- Financial goals with target amount and monthly contribution
- Emergency fund (dedicated goal type)
- Contribution history per goal
- Progress tracking (% complete, months to reach target)

### Lending

- Track money lent to and borrowed from people
- Partial settlement support
- Per-person balance summary

### Expense Contributions (Split Expenses)

- Add contributors when creating or editing an expense
- Auto-equal split with manual override per person
- Include/exclude yourself from the split
- Overage prevention (shares cannot exceed total expense)
- Settle/unsettle individual contributions
- Effective amount (`amount - recoveredAmount`) used across analytics, history, calendar, budget, and home
- "₹X recovered" label on transaction rows when contributions are settled
- PDF invoice export with contributor table, status, and summary (branded, matches analytics styling)
- Reactive stream updates — settle/unsettle instantly reflects everywhere

### Privacy & Security

- Biometric lock (fingerprint / face / PIN) on app resume
- Hide all financial amounts with a single toggle
- All data stored locally on device

### Notifications

- Daily reminder notification
- Budget alert when spending approaches the monthly limit

### Cloud Sync

- Google account sign-in with disconnection support
- Automatic daily backup on app launch
- Manual backup and restore
- Backup status with last backup date/time display
- Restore confirmation dialog with backup metadata (date, source device)

### Settings

- Currency setting
- Theme mode (system / light / dark)
- Monthly budget configuration
- Notification preferences (daily reminder, budget alerts)
- Privacy lock toggle
- Amount visibility toggle
- Data export and import (JSON)
- Clear all data with reseed

### Activity

- Event log of significant user actions (add/edit/delete transaction, sync, settings changes)
- Daily screen time accumulation
- Activity screen with recent events and usage stats

### Onboarding

- Profile setup on first launch (name, email, phone)
- Routes directly to home on subsequent launches

---

## In Progress

- Monthly reflections UI (data layer: table, entity, repository, and providers exist; needs page to view and edit notes)

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