# Changelog

## [1.8.0] - 2026-11-10

### Improvements

- **Spend snapshot card compacted (188 → 166px)**: The balance block now hugs the label row instead of floating in dead space. The goal-allocation chip sits on the lower-left edge with `Tap for transactions →` on the right edge of the same row.
- **Spend chart now sits in its own zone**: The background chart no longer runs under the bottom row or into the "Available to spend" text — it occupies the free right-hand area (below the label row, above the hint row), taller than before, with its left edge anchored at a fixed inset so it stays clear of the text on every screen width. Every bar from day 1 of the month stays fully visible.
- **Home spend-snapshot "goal allocation" line is now a native pill**: When you have money allocated to goals this month, the black card shows `₹X to goals` as a compact chip — gold dot, bold amount, soft gold tint background. The eye-hide toggle masks the chip amount as before.
- **Recent Transactions grouped in one bordered card**: The home ledger rows are wrapped in a single standard `HomeSurfaceCard` (24px radius, hairline border, no extra padding) with hairline dividers between rows, matching the other home cards. The section header and "View all" stay outside the card; scrolling, row taps, and swipe actions are unchanged.
- **New design token**: `AppColors.gold` (`#F5B83D`) for the goal-allocation chip accent.
- **Today's Spend / Remaining cards revamped (170 → 136px)**: Both metric cards are now minimal surfaces — no icon tiles, top accent strip, or watermark ring. They keep the standard card surface fill and hairline border (same as the snapshot and investment cards), and each shows a small uppercase label with a single top-right indicator, a 26px Bricolage amount, and one quiet bottom line. Both label rows are a fixed 30px tall so the labels and amounts sit on the same baseline across the pair. The pair shows the same data and keeps both tap targets (left → Transactions, right → Budget).
- **Remaining percentage moved into a 30px progress ring**: The percentage now sits inside a small ring beside the `REMAINING` label (lavender stroke on a quiet track) instead of a separate watermark. Over budget shows a full red ring with `!`, a red amount, and `over by ₹X`; no budget hides the ring entirely and shows `—` + `Tap to set monthly budget`.
- **Lend & Borrow home card simplified**: Replaced the three nested boxes (two tinted mini-cards + an "active people" tile) with one flat card at the investment card's 14px radius: `LEND & BORROW` plus the people count in the header, and two amounts split by a hairline divider — `TO RECEIVE` (green dot) and `YOU OWE` (red dot). Zero sides render muted; the whole card still opens `/lend`, and the amount-masking toggle still hides both values. Removed the now-unused `_MiniMetricCard` widget.

## [1.7.0] - 2026-11-09

### Added

- **Goal contributions now track their source**: Every goal / emergency fund contribution is recorded as `manual` (money you put in) or `interest` (money the bank paid into the goal). A new **Add Interest** action lives in the goals page "more" sheet alongside Withdraw and History, with interest entries badged in the history sheet and an "Interest earned" total per goal.
- **Interest never touches your spendable balance**: The home screen "allocated to goals this month" amount and the derived *available to spend* now count manual contributions only — interest grows the goal without double-counting against your wallet.

### Database

- Schema version 28 → 29: `goalContributions` gained a `source` column (`manual` | `interest`, default `manual`). Existing data migrates in place; nothing is lost.
- Backup JSON export/import include the contribution source. Old backups import cleanly (missing sources default to `manual`), and new backups stay importable by older app versions.

## [1.6.0] - 2026-09-18

### Removed

- **Split expenses (expense contributors) removed entirely**: The feature was unused, so all contributor logic, the settle/unsettle flow, and the contribution PDF export were stripped out. Expense totals, analytics, calendar, and budget now always count the full amount — no hidden `recoveredAmount` math anywhere.

### Improvements

- **Time-aware greeting**: Header now greets you by the time of day — Good morning (5 AM–12 PM), Good afternoon (12 PM–5 PM), Good evening (5 PM–9 PM), Good night (9 PM–5 AM).

### Bug Fixes

- **Custom date-range filter no longer drops the last day**: Filtering e.g. "Sep 1 – Sep 15" now includes all of Sep 15 instead of stopping at midnight.
- **Calendar no longer clips the month**: The grid was hard-capped at 5 rows, hiding the last days of months that need a 6th row (e.g. a 31-day month starting Friday). It now always renders 6 rows.
- **Lend over-settlement fixed**: Settlements are now capped at the *remaining* balance (`amount − settled`) instead of the full amount, and editing an entry no longer silently inflates its amount to match settled payments.
- **Recurring rules no longer drift**: Rules starting on the 29th–31st (or Feb 29) clamp to the last valid day of each month (e.g. Jan 31 → Feb 28) instead of rolling over to the 1st and drifting forever.
- **Privacy lock gate now renders reliably on slow first launch** (fixed a widget-level state error during boot).

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
