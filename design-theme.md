# Spendly Design Theme Audit

Last updated: 2026-11-10
Owner: Product + Engineering

## Purpose
This document tracks Spendly's visual language and audit status across tokens, components, and screens. Use it as the source of truth before shipping UI changes.

## Design Direction
- Noir fintech
- Black/white minimalist
- Premium and cinematic
- High readability
- Clean hierarchy over decoration

## Core Foundations

### Typography
- Heading font: `Bricolage Grotesque` (600/700)
- Body font: `Inter` (400/500/600)
- Amount emphasis: `Inter` 600/700
- Source:
  - `lib/core/theme/app_typography.dart`
  - `lib/core/theme/app_theme.dart`

Audit status:
- Font family compliance: Pass
- Centralized text theme usage: Partial (many screens still use inline `TextStyle`)

### Spacing
Scale:
- `4, 8, 12, 16, 20, 24, 32, 40`
- Source: `lib/core/theme/app_design_tokens.dart`

Audit status:
- Token availability: Pass
- Consistent adoption: Partial

### Color and Surfaces
- Primary noir palette and border tokens in `AppColors`
- Goal-allocation accent: `AppColors.gold` (`#F5B83D`)
- Source: `lib/core/theme/app_design_tokens.dart`

Audit status:
- Token system: Pass
- Hardcoded color reduction: Partial

### Icons
- Standard icon set: Lucide via `AppIcons`
- Source: `lib/core/theme/app_icons.dart`

Audit status:
- System in place: Pass
- Full migration from `Icons.*`: Partial

## Component Standards

### App Bar
- Use: `NoirHeader`
- Status: Mostly consistent
- Follow-up: Replace remaining Material icon defaults/fallbacks in header internals

### Buttons
- Use: `AppButtonStyles`
  - Primary, Secondary, Danger, Ghost
- Status: Partial adoption

### Dialogs
- Use: app-level `AlertDialog` theme + `DialogActionsRow`
- Status: Partial adoption
- Follow-up: remove custom `Theme(...)` wrappers in legacy dialogs

### Bottom Sheets
- Use: `AppModalSurface` + token spacing
- Status: Partial adoption

### Cards
- Prefer subtle contrast and spacing over heavy borders
- Home metric pair is the reference for minimal cards: standard card surface + hairline border at 26px, uppercase 10px label with a fixed 30px label row, 26px Bricolage amount, one 11px support line, single top-right indicator
- Home Lend & Borrow card follows the flat pair pattern: one surface at the investment card's 14px radius, header label + people count, two amounts split by a hairline divider, color-coded dots instead of tinted boxes
- Home Recent Transactions list is grouped in one standard bordered card (24px) with hairline row dividers; the section header stays outside
- Status: Partial (home metric pair and Lend & Borrow card Pass; other cards still use bordered `HomeSurfaceCard`)

## Screen Audit Tracker

Legend:
- `Pass`: aligned with design system
- `Partial`: mostly aligned, still has drift
- `Needs Work`: major drift from system

| Screen | Typography | Icons | Spacing | Dialog/Sheet | Surface/Border | Status |
|---|---|---|---|---|---|---|
| Home (`features/home`) | Partial | Partial | Partial | N/A | Partial | Partial |
| Transactions list | Partial | Pass | Pass | Pass | Partial | Partial |
| Add transaction sheet | Partial | Partial | Partial | Partial | Partial | Partial |
| Calendar | Partial | Pass | Pass | N/A | Partial | Partial |
| Insights | Partial | Pass | Pass | N/A | Partial | Partial |
| Budget | Partial | Partial | Partial | Partial | Partial | Partial |
| Settings | Partial | Partial | Partial | Partial | Partial | Partial |
| Notifications | Partial | Partial | Partial | N/A | Partial | Partial |
| Categories | Partial | Partial | Partial | Partial | Partial | Partial |
| Recurring | Partial | Partial | Partial | Partial | Partial | Partial |
| Lend list | Partial | Pass | Partial | Partial | Partial | Partial |
| Lend detail | Partial | Partial | Partial | Needs Work | Partial | Needs Work |

## Audit Checklist (Use Per PR)
- Typography uses `textTheme` styles where possible
- No non-approved font families
- Spacing values use `AppSpacing`
- Icons use `AppIcons` (Lucide)
- Dialog actions use `DialogActionsRow`
- Bottom sheets use `AppModalSurface`
- Borders are intentional (no visual noise)
- Dark mode readability remains high
- Money values show proper precision where needed

## Known Drift Backlog
1. Replace remaining `Icons.*` usages with `AppIcons` mappings.
2. Replace repeated inline `TextStyle` blocks with semantic `textTheme` styles.
3. Remove legacy custom dialog themes and use global dialog tokens.
4. Normalize `BorderRadius.zero` usage to token radii where appropriate.
5. Reduce hardcoded `Color(0xFF...)` references in feature screens.

## Update Protocol
When finishing UI work:
1. Update relevant screen row status.
2. Add/remove items in Known Drift Backlog.
3. Update `Last updated` date.
4. Mention this file in PR summary.
