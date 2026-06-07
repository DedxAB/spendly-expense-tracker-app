# Architecture

## Overview

Spendly is an offline-first personal finance application built with Flutter.

The application follows a feature-first architecture where every major business capability is isolated into its own module.

Goals of the architecture:

- Offline-first experience
- Clear feature boundaries
- Maintainable codebase
- Scalable growth
- Fast local performance

---

## Technology Stack

### Framework

- Flutter

### State Management

- Riverpod

### Local Storage

- Drift
- SQLite

### Navigation

- GoRouter

### Models

- Freezed
- JSON Serializable

### Notifications

- Flutter Local Notifications

### Authentication

- Local Authentication
- Google Sign-In

---

## Project Structure

```text
lib/

├── app/
├── core/
├── features/
└── main.dart
```

---

## App Layer

Responsible for:

- Application bootstrap
- Routing
- Global app configuration

```text
app/
├── app_router.dart
└── spendly_app.dart
```

---

## Core Layer

Shared infrastructure used across features.

```text
core/
├── constants/
├── database/
├── error/
├── logger/
├── notifications/
├── theme/
├── utils/
└── widgets/
```

### Responsibilities

#### database

Local persistence using Drift and SQLite.

#### notifications

Budget alerts and reminder notifications.

#### logger

Centralized logging.

#### theme

Application design system and visual consistency.

#### widgets

Reusable UI components.

---

## Feature Modules

Each feature owns its own logic, providers, repositories, entities, and UI.

### Activity

Tracks user activity and engagement metrics.

### Categories

Manages transaction categories.

### Cloud Sync

Handles Google account integration and backup/sync functionality.

### Goals

Financial goal tracking and progress management.

### Home

Dashboard and financial overview.

### Insights

Analytics, trends, reflections, and spending breakdowns.

### Lend

Lend and borrow tracking.

### Recurring

Recurring transactions and subscriptions.

### Settings

Application preferences and privacy settings.

### Transactions

Income and expense management.

### User

User profile and account-related functionality.

---

## Architectural Principles

### Offline First

Local database is the source of truth.

### Feature Isolation

Features remain independent whenever possible.

### Reusable Core

Infrastructure belongs in core rather than feature modules.

### Reactive State

Riverpod providers drive UI updates through reactive state management.

---

## Future Direction

- Smarter financial insights
- Enhanced backup system
- Import/export support
- AI-assisted transaction discovery
