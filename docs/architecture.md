# Architecture

## Overview

Spendly is an offline-first personal finance app built with Flutter. Every feature is isolated into its own module. The local SQLite database is the single source of truth — no internet connection is required for any core functionality.

---

## Technology Stack

| Concern | Library |
|---|---|
| Framework | Flutter |
| State Management | Riverpod 2.6.1 |
| Local Database | Drift 2.25.0 + SQLite |
| Navigation | GoRouter 14.8.1 |
| Immutable Models | Freezed 2.4.4 |
| Charts | fl_chart 0.71.0 |
| Notifications | flutter_local_notifications 17.2.3 |
| Biometric Auth | local_auth 3.0.1 |
| Cloud Backup | Google Sign-In 6.2.2 + Google Drive |

---

## Project Structure

```text
lib/
├── main.dart           ← App entry point
├── app/
│   ├── app_router.dart ← All routes defined here
│   └── spendly_app.dart← Root widget, bootstrap logic
├── core/
│   ├── constants/      ← App-wide constants
│   ├── database/       ← Drift DB, all tables, DAO mixins
│   ├── error/          ← Failure types
│   ├── logger/         ← Centralized logging
│   ├── notifications/  ← Budget alerts & daily reminders
│   ├── theme/          ← Design system (colors, text styles)
│   ├── utils/          ← Formatters, date helpers
│   └── widgets/        ← Shared UI components
└── features/
    ├── activity/       ← Usage tracking & event log
    ├── categories/     ← Transaction categories (CRUD)
    ├── cloud_sync/     ← Google Drive backup & restore
    ├── goals/          ← Financial goals & contributions
    ├── home/           ← Dashboard overview
    ├── insights/       ← Charts, trends, analytics
    ├── lend/           ← Lend/borrow tracking
    ├── recurring/      ← Scheduled recurring transactions
    ├── settings/       ← App preferences & budgets
    ├── transactions/   ← Income & expense management
    └── user/           ← User profile & onboarding
```

Each feature follows this internal structure:

```text
feature/
├── data/
│   ├── repositories/   ← Concrete implementation (talks to DB)
│   └── services/       ← External APIs (e.g. Google Drive)
├── domain/
│   ├── entities/       ← Freezed immutable models
│   └── repositories/   ← Abstract interface
└── presentation/
    ├── pages/          ← Screens
    ├── providers/      ← Riverpod providers
    └── widgets/        ← Feature-scoped UI components
```

---

## App Bootstrap Flow

```text
main.dart
  └── ProviderScope
        └── SpendlyApp
              ├── recurringBootstrapProvider  ← process any overdue recurring rules
              ├── settingsStreamProvider      ← watch settings for budget alerts & reminders
              ├── PrivacyLockGate             ← wrap entire UI for biometric lock
              └── MaterialApp.router (GoRouter)
                    └── SplashPage
                          ├── run daily cloud backup if needed
                          ├── check onboardingCompleted flag
                          ├── → /onboarding/profile  (first launch)
                          └── → /home               (returning user)
```

---

## Navigation Structure

GoRouter handles all navigation. The main shell has a bottom navigation bar with five tabs.

```text
/splash
/onboarding/profile

/home  ← ShellRoute (AppShell with bottom nav)
  ├── /home          → HomePage
  ├── /transactions  → TransactionsPage
  ├── /insights      → InsightsPage
  ├── /budget        → BudgetPage
  └── /goals         → GoalsPage

Additional routes (accessible from anywhere):
  /transactions/new?type=expense|income|investment  → AddTransactionPage
  /calendar                             → CalendarPage
  /settings                             → SettingsPage
  /categories                           → CategoriesPage
  /recurring                            → RecurringPage
  /lend                                 → LendPage
  /lend/:personId                       → LendPersonDetailPage
  /activity                             → ActivityScreenTimePage
  /notifications                        → NotificationsPage
```

---

## State Management

All state is managed with Riverpod. Three patterns are used depending on the use case.

### StreamProvider — real-time DB watches

Used whenever the UI must reflect the latest database state instantly.

```text
DB change → Drift stream emits → StreamProvider notifies → Widget rebuilds
```

Example: `settingsStreamProvider` watches the settings row. Any change (budget update, toggle) automatically refreshes every widget that reads it.

### Provider (computed) — derived / calculated data

Reads one or more other providers and derives a result. No async IO.

```text
monthlyTotalsProvider + settingsStreamProvider → dashboardSummaryProvider
```

Example: `dashboardSummaryProvider` combines monthly income/expense totals with the monthly budget setting to produce `balance`, `remainingBudget`, etc.

### FutureProvider — one-time async operations

Used for tasks that run once on startup.

Example: `recurringBootstrapProvider` calls `processDueRules()` once when the app starts to generate any overdue recurring transaction instances.

### StateNotifier — local UI state

Used for filter/sort controls that live only in the presentation layer.

Example: `TransactionFilterController` tracks the active month, type filter, and category filter on the transactions screen.

---

## Data Flow (End to End)

```text
User taps "Add Expense"
        ↓
AddTransactionPage collects input
        ↓
calls transactionsRepositoryProvider.add(entity)
        ↓
TransactionsRepositoryImpl writes to Drift (SQLite)
        ↓
Drift emits new value on all active watch streams
        ↓
StreamProviders (totals, recent, dashboard) re-evaluate
        ↓
Riverpod notifies listening widgets
        ↓
HomePage balance card, InsightsPage charts update automatically
```

---

## Feature Modules

### Home

Dashboard screen. Shows:

- Current balance (income − expense for the month)
- Today's spend vs yesterday
- Remaining monthly budget
- Last 5 transactions
- Upcoming recurring transactions
- Lend/borrow quick summary

Providers: `dashboardSummaryProvider`, `todaySpentProvider`, `yesterdaySpentProvider`, `recentTransactionsProvider`

---

### Transactions

Full transaction history with filtering. Supports:

- Add / edit / soft-delete transactions
- Support for income, expense, and investment transaction types
- Filter by month, type (income/expense/investment), category
- Search by note or amount
- Sort by date or amount
- Calendar view grouped by date
- Restore deleted transactions

Key providers: `transactionsProvider`, `monthlyTotalsProvider`

---

### Categories

User-defined categories for organising transactions. Each category has a name, icon, color, and type (expense or income). A set of default categories is seeded on first launch from `default_categories.dart`.

---

### Recurring Transactions

Rules that automatically generate transaction instances on their due dates.

Supported frequencies: daily, weekly, monthly, yearly.

On every app launch, `recurringBootstrapProvider` calls `processDueRules()` which:

1. Queries all active rules where `nextDueDate <= today`
2. Creates a transaction instance for each rule
3. Advances `nextDueDate` to the next cycle
4. Supports "delete this and future" to stop a rule from a specific date

---

### Goals

Tracks savings goals and an emergency fund.

- Each goal has a target amount, saved amount, and optional monthly contribution
- Contributions are logged as individual events
- Calculated fields: `progress` (%), `remaining`, `monthsCovered`
- Emergency fund is a special goal flagged with `isEmergency = true`

---

### Insights

Analytics and spending breakdowns. All data comes from aggregating the transactions table.

Charts and metrics available:

- Expense trend (daily or monthly line chart)
- Expense distribution by category (ranked list with spend and % change)
- Income vs expense comparison (bar chart)
- Yearly income vs expense (monthly bars)
- Payment mode breakdown (cash / card / UPI, in PDF export)
- Burn rate card with projected monthly expense
- Budget progress bar with remaining/over indicator
- Month-over-month spending change percentage
- "What's Changed" natural-language insights
- Trend snapshot (active periods, peak spending)
- PDF export of full analytics report

---

### Lend

Tracks money lent to or borrowed from people.

Flow:

```text
Add person → Add lend/borrow entry → Apply settlements over time
```

- Each person has a running balance (total lent − total settled)
- Partial settlements are supported
- `LendOverview` is computed from entries and settlements per person

---

### Settings & Budget

- Monthly budget setting (used in dashboard for remaining budget)
- Per-category budget (tracked separately in `CategoryBudgets` table)
- Daily reminder toggle (schedules/cancels local notification)
- Privacy lock toggle (enables biometric on app resume)
- Amount visibility toggle (hides all financial figures)
- JSON export / import (used for cloud backup)
- Clear all data

---

### Cloud Sync

Optional Google Drive backup. The local database is the source of truth; Drive is only for disaster recovery.

Flow described in [backup.md](backup.md).

---

### Activity

Logs every significant user action (add transaction, change setting, sync) as an `ActivityEvent` and accumulates daily screen time in `AppUsageDays`.

---

### User Profile

Single user profile (id = 1). Stores name, email, phone, and `onboardingCompleted` flag. Only used to personalize the UI and gate the onboarding flow.

---

## Key Design Decisions

| Decision | Reason |
|---|---|
| Amounts stored in paise | Avoids floating-point precision errors (1 ₹ = 100 paise) |
| Soft deletes everywhere | Allows undo; preserves referential integrity |
| Streams for all DB reads | UI always reflects current state without manual refresh |
| Recurring rules vs instances | Rules define the schedule; instances are real transactions |
| Single user, single settings row | Keeps schema simple; no multi-user complexity |
| JSON export for backup | Human-readable; easy to restore without a server |
