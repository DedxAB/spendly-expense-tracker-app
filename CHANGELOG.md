# Changelog

## [1.5.0] - 2026-07-10

### Expense Contributions (Split Expenses)

- **Split expenses with others**: Add contributors when creating an expense — each person gets an equal share by default, with manual override via tappable amounts
- **Include/exclude self toggle**: Optionally include yourself in the split; your share auto-calculates as the remainder
- **Overage prevention**: Save is blocked when total shares exceed the expense amount
- **Settle / unsettle contributions**: Mark individual contributors as paid/unpaid from the settle sheet
- **Effective amount tracking**: All analytics, history totals, calendar, budget, and home screen use `amount - recoveredAmount` for accurate spend visibility
- **Recovery indicator**: Transaction rows show a green `₹X recovered` label below the amount when contributions are settled
- **Contribution PDF export**: Branded invoice PDF with contributor table, settlement status, and summary — follows analytics PDF styling
- **Reactive updates**: Settling/unsettling a contribution instantly refreshes all transaction streams without app restart

### UI Polish & Consistency

- **Balance Masking**: Replaced `******` and `████` block masking with vertical rectangle bars — one bar per digit, with customizable color, width, height, and spacing. Applied consistently across the entire app via new `AmountView` / `AmountMask` widgets.

- **Home Screen**:
  - Added investment card showing monthly investment amount, percentage of income, and progress bar
  - Added recurring transactions banner with upcoming rule title and next due date
  - Reordered layout: investment card → lend & borrow card → recurring banner → recent transactions
  - FAB now uses black background in light mode, white in dark mode

- **Card Border Radii**: Standardized all card radii to `AppRadii.lg` (14) across the app for a tighter, more cohesive look — categories, budget, notifications, transactions, and recurring pages.

- **Notifications Page**: Full revamp with icon-based cards, color-coded badges, tappable notification preferences, and proper dark/light mode support.

- **Icons**: Lend & borrow section header icon changed to `handCoins`; recurring banner uses `repeat` icon; FAB `plus` icon maintained.

- **Categories Page**: Delete button background/border colors now adapt to dark/light mode.

### Bug Fixes

- Fixed gap between lend/borrow card and recurring banner on home screen
