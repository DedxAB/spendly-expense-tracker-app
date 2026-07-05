# Changelog

## [1.4.0] - 2026-07-05

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
