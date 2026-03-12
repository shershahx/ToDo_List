# To-Do List App — Week 1 & 2

## Overview
A Flutter application developed as part of a two-week Flutter internship. Week 1 built the UI shell (splash, login, sign-up, navigation, validation). Week 2 adds state management, local persistence, a counter app, a fully functional to-do list with due-date notifications, and persistent session management so users stay logged in across restarts.

## Features

### Week 1 — UI & Navigation
- **Splash Screen:** 2-second branded launch screen; auto-routes based on session state.
- **Login Screen:** Dark-themed UI with email + password fields and a "Forgot Password?" dialog.
- **Sign Up Screen:** Name, email, password, and confirm-password with strict validation rules.
- **Form Validation:** Email format check, password strength (8+ chars, mixed case, number, symbol), alphabets-only name input filter.
- **Navigation:** Login → Home via `pushReplacement`, Sign-up → Login, Logout clears session and returns to Login.
- **Demo Account:** Built-in credentials for quick testing without registering.

### Week 2 — State Management, Storage & Notifications
- **Session Management:** Login state is persisted with SharedPreferences. The app skips the login screen automatically on relaunch until the user explicitly logs out.
- **Counter App:** Increment, decrement (supports negative values), and reset a counter using `setState`. Value persists across restarts. Reset button only appears when counter ≠ 0.
- **To-Do List:**
  - Add tasks via a bottom sheet (feels native, no jarring dialog).
  - Optional due date + time picker when creating a task.
  - Pending and Completed sections are visually separated.
  - Tap a task or its checkbox to toggle completion — no line-through text; completed tasks show a green "Done" badge.
  - Swipe left or tap the × icon to delete; undo snackbar restores the task.
  - Overdue tasks show a red border and "Overdue" label.
- **Due Date Notifications:** Scheduling a due date automatically sets a local notification reminder. Notifications cancel when a task is completed or deleted.
- **Progress Tracker:** Circular progress indicator with percentage and "X of N completed" count.
- **SharedPreferences:** Tasks (JSON), counter value, and session state all persist locally — zero data loss on restart.

## Demo Credentials

| Field    | Value              |
| -------- | ------------------ |
| Email    | `demo@todoapp.com` |
| Password | `Demo@1234`        |

Or create your own account via **Sign Up**.

## Project Structure

```
lib/
├── main.dart                      — App entry point, global dark theme
├── screens/
│   ├── splash_screen.dart         — Launch screen, checks session on startup
│   ├── login_screen.dart          — Login with validation, saves session on success
│   ├── signup_screen.dart         — Registration with validation
│   ├── home_screen.dart           — To-do list with due dates, sections, progress
│   └── counter_screen.dart        — Counter app (setState + SharedPreferences)
└── utils/
    ├── colors.dart                — Centralized dark-mode color palette
    ├── validators.dart            — Reusable form validators
    ├── user_store.dart            — In-memory user registry (auth)
    ├── session_manager.dart       — SharedPreferences-backed login session
    └── notification_service.dart  — Local notification scheduling & cancellation
```

## Getting Started

1. Install Flutter — [flutter.dev](https://flutter.dev)
2. Clone the repository.
3. Run `flutter pub get` to fetch dependencies.
4. Connect a device or start an emulator.
5. Run `flutter run`.

> **Android note:** The app requests notification permission at runtime (Android 13+). Allow it to receive due-date reminders.

## Key Packages

| Package                       | Purpose                                        |
| ----------------------------- | ---------------------------------------------- |
| `shared_preferences`          | Persist tasks, counter, and session locally    |
| `flutter_local_notifications` | Schedule and cancel due-date reminders         |
| `timezone`                    | Correct timezone handling for notifications    |
| `intl`                        | Date/time formatting ("Today", "Tomorrow", …)  |
| `cupertino_icons`             | iOS-style icons                                |

## Learning Objectives Addressed

**Week 1**
- Understand Flutter's basic project structure.
- Build responsive UIs with Column, Row, Container, Form, TextFormField.
- Navigate between screens using `Navigator.push` / `pushReplacement` / `pop`.
- Validate forms (email format, password strength, required fields).

**Week 2**
- Manage widget state with `setState`.
- Persist and retrieve primitive values and structured data using `SharedPreferences`.
- Build a `ListView`/`CustomScrollView`-based to-do list with add, complete, and delete operations.
- Restore app state on restart using persisted JSON data.
- Implement session management so users remain logged in between launches.
- Schedule local push notifications tied to task due dates using `flutter_local_notifications`.

