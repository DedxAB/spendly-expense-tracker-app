# Spendly · Google Stitch Prompt Pack

Use this to generate the full Spendly UI in Google Stitch, then export to Figma.
All prompts describe the **same functionality that exists in the app today** — nothing added, nothing removed.

---

## How to use

1. **Best results:** Stitch works best per-screen. Start a new project, paste the **Master Prompt** first (it sets the style reference), then paste one **Screen Prompt** at a time. Use "generate more" to extend the set.
2. **One-shot option:** if you want a single prompt for everything, use the **All-Screens Prompt** below. Expect Stitch to fully render the first few screens and summarize the rest — you can then ask for each remaining screen by name.
3. **Style sync tip:** attach a screenshot of the current Spendly app to the prompt as an image reference — Stitch copies the visual language much more faithfully than text alone.
4. After exporting to Figma, all frames are mobile (390 × 844).

---

## Master Prompt (paste first)

```
Design a premium dark-mode personal finance mobile app called "Spendly" for India. Currency is ₹ with Indian digit grouping (₹2,48,320). Visual direction: "noir fintech" — black-and-white minimal, premium, cinematic, high readability, clean hierarchy over decoration. Dark mode is primary. No glassmorphism, no neon glows, no heavy shadows, no decorative gradients.

COLORS (dark): canvas #050505, card surface #101112, elevated surface #161616, hairline border #26282B, primary text #F5F5F5, secondary text #9A9A9A, faint text #565656. Semantic accents: green #38D97A (income, receive, on track), red #FF5C6C (expense, owe, over budget), purple #8B5CF6 (investments, goals, analytics), amber #F5B83D (warnings, budget line, goal-allocation chip). Light mode variant: canvas #F7F7F7, surface #FFFFFF, border #E0E0E0, text #111111, secondary #666666.

TYPOGRAPHY: Bricolage Grotesque (600/700) for page titles, card headings and large monetary figures; Inter (400/500/600) for all UI text. Tabular numerals for every amount. Hero balance 40–46px, card amounts 20–24px, uppercase micro-labels 10–11px with 0.12em tracking, body 13–14px, captions 12px.

SHAPE & SPACING: standard cards 24px radius, hero card 28px, icon tiles 12–14px, chips and buttons fully rounded pills, header icon cards 48×48 bordered squares; spacing scale 4/8/12/16/20/24/32/40; page side padding 12–16px.

GLOBAL CHROME: 70px top header. Home mode: 48px rounded profile avatar on the left, "Hi, {firstName}" in bold above a time-of-day greeting, two bordered 48px icon cards on the right (settings gear, bell). Inner pages: bordered 48px back-arrow card and a centered page title. 62px bottom navigation with 5 tabs — Home, History, Analytics, Budget, Goals — Lucide outline icons, selected tab has a 2px top indicator and full-opacity label. Circular black FAB with a white plus at bottom right. Lucide outline icons everywhere, 1.8px stroke.

COMPONENT LANGUAGE: hairline-bordered cards on near-black surfaces; flat ledger rows with hairline dividers for lists; pill filter chips that invert to black when active; segmented controls with a raised selected pill; bottom sheets with a drag handle; tinted mini-cards for money direction (green = receive, red = owe); monochrome primary actions; amounts right-aligned with tabular numerals and explicit +/− signs. Generous vertical rhythm, no clutter, no illustrations except a small empty-state glyph.
```

---

## All-Screens Prompt (single shot)

```
Design the complete mobile UI for "Spendly", a premium personal finance tracker for India (₹, Indian digit grouping). Produce a consistent set of mobile screens 390×844 that all share one design system, using the Spendly noir design language below.

DESIGN LANGUAGE: black-and-white minimal, premium, cinematic, high readability, clean hierarchy over decoration. Dark mode primary. No glassmorphism, no neon, no heavy shadows, no decorative gradients. Colors: canvas #050505, card surface #101112, hairline borders #26282B, text #F5F5F5, secondary #9A9A9A; green #38D97A for income/receive/on-track, red #FF5C6C for expense/owe/over-budget, purple #8B5CF6 for investments/goals/analytics, amber #F5B83D for warnings and the goal chip. Typography: Bricolage Grotesque bold for titles and money, Inter for UI, tabular numerals everywhere. Shapes: 24px cards, 28px hero card, pill chips, 48px bordered icon cards, spacing 4/8/12/16/20/24/32/40. Chrome: 70px header (home: 48px avatar + "Hi, {name}" + greeting + settings/bell icon cards; inner: back-arrow card + centered title), 62px bottom nav (Home, History, Analytics, Budget, Goals), circular black FAB with white plus, Lucide outline icons at 1.8px stroke.

1. HOME: noir "SPEND SNAPSHOT" hero card (28px radius) with "Available to spend", large balance, small green bar-and-line sparkline on the right, an eye icon to mask amounts, and a gold pill chip "₹20,000 to goals"; below it two 170px metric cards side by side — "TODAY'S SPEND ₹1,240" with green "−12% vs yesterday" and a 3px green top accent, and "REMAINING ₹24,300" with purple top accent, "of ₹40,000 limit" and a faint progress ring; an "INVESTMENT" card with purple percentage-of-income progress bar; a "LEND & BORROW" card with two tinted mini-cards (green "You Will Receive ₹4,500", red "You Owe ₹1,200") and a "3 active people" row; a recurring-payment banner; then a flat "Recent Transactions" ledger with hairline dividers and signed right-aligned amounts.
2. TRANSACTIONS: filter chip row (Filter, Date, Type, Payment, Category, Amount, Sort — active chips inverted black), day-group headers with daily total, rows with a 40px category icon tile, title, category/payment caption and signed amount, "Show more" pagination, swipe-to-edit/delete hints, empty state "No transactions yet".
3. ADD TRANSACTION bottom sheet: drag handle, "Add Transaction", centered ₹ amount input with 0.00 hint, Expense/Income/Investment segmented control, horizontal category chips plus a "+" chip, UPI/Card/Cash segmented control, optional card type, date row, optional note, primary "Save expense" button.
4. CALENDAR: month navigator, "TOTAL SPENDING" header, 42-cell month grid with compressed daily amounts (₹1.2k), today and selected-day outlines, selected-day expense list below, expense-only.
5. ANALYTICS: month/year navigator with Monthly/Yearly toggle, softly tinted overview card (total spent, income, burn rate per day, green "SAVED ₹X · N%" or red "OVERSPENT" pill, "% vs last month"), budget usage block with projected spend, "Spending by Category" list with up/down delta chips, trend line chart with a dashed amber budget line and tooltip, two snapshot stat tiles ("Active weeks", "Peak week"), "What's Changed" insight bullets, full-width "Download PDF Report" button.
6. BUDGET: monthly summary card with "ON TRACK" or "OVER BUDGET" pill, spend vs budget, progress bar, % used, remaining, "Safe to Spend ₹X / day", days left; per-category budget cards with NO LIMIT / ON TRACK / OVER pills and usage bars; "Edit Budget" sheet.
7. GOALS: pill tabs "Goals" and "Emergency", summary with progress ring, total saved, "on track" and monthly contribution chips; deadline urgency banner; goal cards with icon, title, status pill, saved/target, progress bar, due date and "Need ₹X/mo", Add and More buttons; emergency fund cards with months-of-coverage; create chooser sheet (Savings goal / Emergency fund) and a contribution sheet (Amount, Reason) with Add, Add Interest, Withdraw and History variants.
8. LEND & BORROW: overview card with green "You Will Receive ₹4,500" and red "You Owe ₹1,200" tiles, people list with initials avatars, active-entry counts and signed net balances, add-person dialog.
9. LEND PERSON DETAIL: person name heading, "You Lent / You Borrowed / Net Balance" summary card, Active and Settled entry groups, entry cards with remaining amount and a "Settle" button, settle dialog with amount and date.
10. RECURRING: rule cards with category icon, title, "Frequency · Payment", amount, pause switch, and status line ("Next: 12 Nov", "Due today", "Overdue · date", "Paused") with a colored top strip when due; add/edit recurring dialog with title, amount, category, frequency (Daily/Weekly/Monthly/Yearly), account and start date.
11. SETTINGS: profile block (avatar, name, transaction-count pill, tracking-since), PREFERENCES group (Account, Notifications, Theme segmented System/Light/Dark, Categories, Lend & Borrow, Recurring, Activity & Screen Time), PRIVACY & LOCKS group (Privacy Shield, Prevent Screenshots, Export JSON, Import Data, Erase All Data), DATA & SYSTEM group (Cloud Sync card with connected email and last backup, budget alerts and daily reminder switches), version footer.
12. NOTIFICATIONS: intro copy, red "You are over budget by ₹X this month" alert card, notification-preferences summary card.
13. CATEGORIES: grouped lists for Expense, Income and Investment with colored icon tiles and delete actions; add/edit category dialog with name field and type segmented control.
14. ACTIVITY & SCREEN TIME: "LIVE" badge card with "Today" and "All time" usage tiles, diagnostic audit trail list with uppercase event titles and right-aligned timestamps.
15. ONBOARDING: centered "What should we call you?", single name field, full-width primary "Continue" button, "Skip for now" text button, generous spacing.

RULES: every screen uses the same header/nav tokens, 24px cards, hairline dividers, pill chips and monochrome actions; amounts right-aligned with tabular numerals and explicit signs; keep layouts uncluttered with a strong vertical rhythm; deliver all screens as linked mobile frames in one cohesive style.
```

---

## Per-screen prompts (recommended)

Prefix every prompt with this shorthand so Stitch keeps the style:

```
Match the Spendly noir design system: dark canvas #050505, 24px cards on #101112 with #26282B hairline borders, Bricolage Grotesque headings, Inter body, green #38D97A / red #FF5C6C / purple #8B5CF6 / amber #F5B83D accents, Lucide outline icons, 70px header, 62px bottom nav, circular black FAB.
```

Then append one of:

**Home**
```
Mobile home screen. Top header: 48px rounded avatar, "Hi, Arnab" bold with "Good evening" beneath, two bordered 48px icon cards (gear, bell). Hero card: "SPEND SNAPSHOT" label, eye icon, "Available to spend", ₹44,800 large, animated green bar+line sparkline top-right, gold pill "₹20,000 to goals" bottom-left with chevron at bottom-right. Two metric cards: "TODAY'S SPEND ₹1,240, −12% vs yesterday" with 3px green top accent; "REMAINING ₹24,300, of ₹40,000 limit" with purple accent and faint percentage ring. "INVESTMENT ₹12,000, 14% of income" with purple progress bar. "LEND & BORROW" card with green "You Will Receive ₹4,500" and red "You Owe ₹1,200" mini-cards, "3 active people" row. Recurring banner "1 recurring txn · Next: Netflix on 12 Nov · ₹649/mo". "Recent Transactions" flat ledger with 4 hairline rows (Swiggy −₹320, Salary +₹61,000, Metro −₹500, Emergency fund −₹5,000). Circular black FAB with plus. Five-tab bottom nav with Home selected.
```

**Transactions**
```
Mobile transaction history. Header with back card and centered "Transactions", calendar icon action. Horizontal filter chips: Filter, Date, Type, Payment, Category, Amount, Sort; "Type: Expense" and "Sort: Newest" chips inverted black. Day group header "Today · Total Spend ₹1,240". Rows: 40px category icon tile, title (Swiggy), caption "Food · UPI · 6:40 PM", right-aligned signed amount (−₹320 red, +₹61,000 green). "Show more (24 left)" button. Swipe-left hint. Empty state variant: receipt glyph and "No transactions yet".
```

**Add Transaction sheet**
```
Mobile bottom sheet over a darkened home screen. Drag handle, "Add Transaction" title and close icon. Centered large ₹ amount input with 0.00 placeholder. Segmented control Expense / Income / Investment (Expense selected). "CATEGORY" horizontal chips (Food selected, Shopping, Transport, Bills, plus a "+" chip). "PAYMENT MODE" segmented UPI / Card / Cash. Date row "Nov 10, 2026". "NOTE (OPTIONAL)" field with "What was this for?". Full-width black "Save expense" button.
```

**Calendar**
```
Mobile spending calendar. Back header "Calendar". Centered "November 2026" with previous/next chevrons. "TOTAL SPENDING" micro-label and ₹41,200 total. 42-cell month grid, Sunday-first, each day with a compressed amount (₹1.2k, ₹840), today outlined, selected day filled dark, adjacent-month days dimmed. Below: "Nov 9" header with daily total and expense-only rows (category icon, note, uppercase category, amount, highest first).
```

**Analytics**
```
Mobile analytics screen. Back header "Analytics", period navigator "November 2026" with Monthly/Yearly toggle. Softly tinted overview card: "OVERVIEW · MONTH", green pill "SAVED ₹33,000 · 40%", large "₹41,200 spent", Income ₹86,000, Burn rate ₹1,373/day, "−12% vs last month". Budget block: "₹15,700 left", usage bar, "39% used", "Projected ₹41,200". "Spending by Category" list of six rows with icon, name, delta chip (+8% / −3%), amount. "Trend" card with line chart, dashed amber budget line, week labels, tooltip. Two tiles: "ACTIVE WEEKS 4 with spend", "PEAK WEEK ₹14,800 · W2". "What's Changed" bullets. Full-width "Download PDF Report" button.
```

**Budget**
```
Mobile budget screen. Back header "Budget". Summary card: "MONTHLY BUDGET · NOVEMBER", green "ON TRACK" pill, "₹15,700 spent of ₹40,000", gradient-free usage bar, "39% used", "₹24,300 remaining", "Safe to Spend ₹810 / day", "30 days left". "Categories" section with Edit action; category cards with icon, name, status pill (ON TRACK / OVER / NO LIMIT), spent/allocated, usage bar, % used and remaining. Over-budget variant: red border and red amounts.
```

**Goals**
```
Mobile goals screen. Back header "Goals". Pill tabs "Goals 3" and "Emergency 1". Summary block: progress ring, "TOTAL SAVED ₹1,20,000 of ₹2,00,000 across 4 funds", chips "On track 3 / 4" and "Monthly ₹20,000". Deadline banner "Japan trip · due in 12 days · need ₹8,000/mo". Goal cards: icon, uppercase title, category caption, status pill (On track green / Behind amber / At risk red), saved/target, progress bar, due timeline, "Need ₹X/mo", Add and More buttons. Emergency card: shield icon, "LIQUIDITY FUND · 01", "4.5 mo coverage", ₹1,80,000 / ₹2,40,000, bar, "% funded". Circular FAB.
```

**Lend & Borrow**
```
Mobile lend & borrow screen. Back header "Lend". "Overview" card with green "You Will Receive ₹4,500" and red "You Owe ₹1,200" tinted tiles. "People" section: rows with initials avatar, name, "2 active entries" caption, right-aligned signed net balance (+₹3,300 green / −₹1,200 red) and "You get / You owe" label, chevron. Circular FAB. Empty state "No people yet. Tap + to add your first person."
```

**Lend person detail**
```
Mobile person detail. Back header. Large person name heading with "Export PDF" and delete icon actions. Summary card: "You Lent ₹6,500", "You Borrowed ₹2,000", divider, "Net Balance +₹4,500" with up arrow. "History" section with "ACTIVE · 2 pending" group: entry cards with "Lent" label, ₹4,000, date, note, settlement chips, "Remaining ₹2,500", "Settle" button. "SETTLED · 1 entry" group with check icon and "Settled 02 Nov". Circular FAB. Settle dialog variant with amount and date.
```

**Recurring**
```
Mobile recurring rules screen. Back header "Recurring". "All Rules" heading. Rule cards: category icon, title (Netflix), "Monthly · UPI" caption, ₹649 amount, status line ("Next: 12 Nov", amber "Overdue · 08 Nov", "Due today", "Paused") with colored top strip for due/overdue, pause switch. Circular FAB. Add dialog: Title, Amount, Category dropdown, Frequency dropdown (Daily/Weekly/Monthly/Yearly), Account segmented UPI/Card/Cash, optional card type, Note, Start Date, Save.
```

**Settings**
```
Mobile settings. Back header "Settings". Profile block: avatar, name, "124 txns" pill, "Tracking since Nov 2026". Group "PREFERENCES": Account, Notifications, Theme with System/Light/Dark segmented control, Categories, Lend & Borrow, Recurring, Activity & Screen Time — icon + label + chevron rows. Group "PRIVACY & LOCKS": Privacy Shield, Prevent Screenshots with switches, Export JSON, Import Data, Erase All Data in red. Group "DATA & SYSTEM": Cloud Sync card with connected email, "Last backup today 9:41 AM", automatic daily backup switch, Connect/Disconnect and Backup now buttons. Budget alerts and Daily reminder switches. Footer: Logout, Privacy Policy, "Version 1.7.0".
```

**Notifications**
```
Mobile notifications. Back header "Notifications". Intro "Stay informed about your finances." Red-tinted alert card "You are over budget by ₹2,400 this month" with OVER badge. "Notification preferences" card: "Daily reminder: On · Budget alerts: On" with chevron.
```

**Categories**
```
Mobile categories. Back header "Categories", circular FAB. Grouped list "EXPENSE / INCOME / INVESTMENT": rows with colored icon tile, category name, red trash icon; hairline dividers. Add Category dialog: name field hint "e.g. Food, Salary", Expense/Income/Investment segmented control, Save.
```

**Activity & Screen Time**
```
Mobile activity screen. Back header "Screen Time". Heading "Activity & Screen Time", subtitle "Audit logs and app usage for your recent Spendly activity." Card with green "LIVE" badge: two tiles "TODAY 1h 12m" and "ALL TIME 42h 18m". "Diagnostic Audit Trail" with "3 days" chip: rows with uppercase event titles, description, right-aligned "TODAY 9:41 AM" timestamps. Empty state "No recent activity yet".
```

**Onboarding**
```
Mobile onboarding, full screen, no app bar. Vertically centered "What should we call you?" in Bricolage Grotesque, single underlined or boxed name field with "Name" hint, full-width black filled "Continue" button, "Skip for now" text button beneath. Generous spacing, near-black canvas.
```

---

## Notes for fidelity

- Keep **dark mode** as the hero design; generate a light-mode pass only after the dark set is coherent.
- The app never uses charts with more than one accent color, drop shadows, or blur — if Stitch adds them, ask it to remove "gradients, glows, shadows and blur".
- Amounts always use `tabular-nums`; Indian grouping (₹2,48,320), never Western (₹248,320).
- The only "special" accent per screen: green for money in, red for money out, purple for goals/analytics/investment, amber for warnings and the goal chip.
