# Database

## Overview

Spendly uses Drift ORM on top of SQLite.

The database is the primary source of truth for all application data.

---

## Why Drift?

Reasons:

- Type-safe queries
- Compile-time validation
- Great Flutter integration
- SQLite performance

---

## Storage Model

Current data categories:

- Transactions
- Budgets
- Recurring transactions
- Settings
- Activity data

---

## Offline First Design

All operations happen locally.

Example flow:

```text
User Action
     ↓
Riverpod Provider
     ↓
Repository
     ↓
Drift
     ↓
SQLite
```

---

## Benefits

- No internet required
- Fast reads
- Fast writes
- Reliable storage

---

## Future Enhancements

Planned:

- Backup metadata
- Import/export support
- Multi-account support