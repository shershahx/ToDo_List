# Task Management App — Flutter Internship (Weeks 1–3)

## Overview
A feature-rich task management application built with Flutter over a three-week internship. The app progresses from a polished login flow (Week 1) through persistent storage and state management (Week 2) to a fully refined task manager with search, filtering, categories, swipe gestures, and secure data storage (Week 3).

## Screenshots

<!-- ![App Screenshot](Screenshot.jpg) -->

## Features

### Week 1 — UI & Navigation
- **Splash Screen:** 2-second branded launch screen; auto-routes based on session state.
- **Login Screen:** Dark-themed UI with email + password fields and a "Forgot Password?" dialog.
- **Sign Up Screen:** Name, email, password, and confirm-password with strict validation rules.
- **Form Validation:** Email format check, password strength (8+ chars, mixed case, number, symbol), alphabets-only name input filter.
- **Navigation:** Login → Home via `pushReplacement`, Sign-up → Login, Logout clears session and returns to Login.
- **Demo Account:** Built-in credentials for quick testing without registering.

### Week 2 — State Management, Storage & Notifications
- **Session Management:** Login state persists locally. The app skips the login screen on relaunch until the user explicitly logs out.
- **Counter App:** Increment, decrement (supports negative values), and reset a counter using `setState`. Value persists across restarts. Reset button only appears when counter ≠ 0.
- **To-Do List:**
  - Add tasks via a bottom sheet with an optional due date + time picker.
  - Pending and Completed sections are visually separated.
  - Tap a task or its checkbox to toggle completion; completed tasks show a green "Done" badge.
  - Swipe left or tap the × icon to delete; undo snackbar restores the task.
  - Overdue tasks show a red border and "Overdue" label.
- **Due Date Notifications:** Scheduling a due date automatically sets a local notification reminder. Notifications cancel when a task is completed or deleted.
- **Progress Tracker:** Circular progress indicator with percentage and "X of N completed" count.
- **SharedPreferences:** Tasks (JSON), counter value, and session state all persist locally — zero data loss on restart.

### Week 3 — Finishing Touches & Final Polish
- **Search:** Real-time task search from the app bar toggles an inline search field; results filter across both pending and completed lists.
- **Filter Chips:** "All", "Pending", and "Completed" choice chips let users quickly narrow the task view.
- **Task Categories:** Assign a color-coded category (Work 🔵, Personal 🟢, Urgent 🔴) when creating a task. Category dots appear on each task tile.
- **Swipe Gestures:** Swipe right to toggle completion, swipe left to delete — with animated background indicators.
- **Onboarding Overlay:** First-time users see a one-time dialog explaining swipe gestures after adding their first task.
- **Custom App Bar:** Greeting-based title (Good morning ☀️ / Good afternoon / Good evening 🌙) with search, counter, and logout action buttons.
- **Custom Page Transitions:** Smooth fade + slide-up animation between screens using a reusable `FadeSlideRoute`.
- **Animated Empty State:** Pulsing icon and slide-in text when the task list is empty.
- **No Results State:** Dedicated UI when search/filter yields zero matches.
- **Custom App Icon:** App-specific launcher icon across Android, iOS, Windows, and Web.
- **Roboto Font:** Custom-bundled Roboto typeface for consistent typography.
- **Security Refactor:** Migrated all persistent data (tasks, session, counter, onboarding) from `SharedPreferences` to `flutter_secure_storage` for encrypted, tamper-resistant storage.
- **Testing & Debugging:** Verified navigation flow, data persistence, notification scheduling, and edge cases using Flutter DevTools.

## Demo Credentials

| Field    | Value              |
| -------- | ------------------ |
| Email    | `demo@todoapp.com` |
| Password | `Demo@1234`        |

Or create your own account via **Sign Up**.

## Project Structure

```
lib/
├── main.dart                      — App entry point, global dark theme, Roboto font
├── screens/
│   ├── splash_screen.dart         — Launch screen, checks session on startup
│   ├── login_screen.dart          — Login with validation, saves session on success
│   ├── signup_screen.dart         — Registration with validation
│   ├── home_screen.dart           — To-do list with search, filters, categories, swipe
│   └── counter_screen.dart        — Counter app (setState + secure storage)
└── utils/
    ├── colors.dart                — Centralized dark-mode color palette + category colors
    ├── validators.dart            — Reusable form validators
    ├── user_store.dart            — In-memory user registry (auth)
    ├── session_manager.dart       — flutter_secure_storage-backed login session
    ├── notification_service.dart  — Local notification scheduling & cancellation
    └── page_transitions.dart      — Reusable fade + slide-up page transition
```

## Getting Started

1. Install Flutter — [flutter.dev](https://flutter.dev)
2. Clone the repository.
3. Run `flutter pub get` to fetch dependencies.
4. Connect a device or start an emulator.
5. Run `flutter run`.

> **Android note:** The app requests notification permission at runtime (Android 13+). Allow it to receive due-date reminders.

## Key Packages

| Package                       | Purpose                                          |
| ----------------------------- | ------------------------------------------------ |
| `flutter_secure_storage`      | Encrypted storage for tasks, session & counter   |
| `shared_preferences`          | Lightweight local key-value persistence          |
| `flutter_local_notifications` | Schedule and cancel due-date reminders           |
| `timezone`                    | Correct timezone handling for notifications      |
| `intl`                        | Date/time formatting ("Today", "Tomorrow", …)    |
| `cupertino_icons`             | iOS-style icons                                  |

## Learning Objectives Addressed

**Week 1**
- Understand Flutter's basic project structure.
- Build responsive UIs with Column, Row, Container, Form, TextFormField.
- Navigate between screens using `Navigator.push` / `pushReplacement` / `pop`.
- Validate forms (email format, password strength, required fields).

**Week 2**
- Manage widget state with `setState`.
- Persist and retrieve primitive values and structured data locally.
- Build a `ListView` / `CustomScrollView`-based to-do list with add, complete, and delete operations.
- Restore app state on restart using persisted JSON data.
- Implement session management so users remain logged in between launches.
- Schedule local push notifications tied to task due dates.

**Week 3**
- Combine all learned concepts into a polished, functional task management app.
- Add, delete, and mark tasks as complete with data persistence.
- Test and debug the app for proper navigation and data integrity.
- Enhance the UI with a custom app bar, action buttons, category colors, and Material icons.
- Implement search, filter, and swipe gestures for a native-feeling UX.
- Migrate to encrypted storage (`flutter_secure_storage`) for security compliance.

## Deadline
**23rd March, 2026**

## Bonus Challenges Completed
- ✅ Splash screen with session-aware routing
