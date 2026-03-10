# To-Do List App — Week 1 & 2

## Overview
A Flutter application developed as part of a two-week Flutter internship. Week 1 focused on UI building, navigation, and form validation. Week 2 adds state management with `setState`, local data persistence with **SharedPreferences**, a counter app, and a fully functional to-do list.

## Features

### Week 1 — UI & Navigation
*   **Splash Screen:** Animated 2-second splash with app icon.
*   **Login Screen:** Dark-themed UI with email + password fields, "Forgot Password?" dialog.
*   **Sign Up Screen:** Name, email, password, confirm-password with strict validation.
*   **Form Validation:** Email format, password strength (8+ chars, mixed case, number, symbol), alphabets-only name filter.
*   **Navigation:** Login → Home, Sign-up → Login, Logout pops back.
*   **Demo Account:** Built-in credentials for quick testing.

### Week 2 — State Management & Persistent Storage
*   **Counter App:** Increment, decrement, and reset a counter using `setState`. Value persists across app restarts via SharedPreferences.
*   **To-Do List:** Add tasks via a dialog, display them in a `ListView`, mark tasks as done (checkbox), delete with swipe or tap, undo-delete snackbar.
*   **Progress Bar:** Live completion percentage and linear progress indicator on the home screen.
*   **SharedPreferences:** All tasks (title + done status as JSON) and the counter value are saved locally and restored on the next launch — zero data loss on restart.

## Demo Credentials

| Field    | Value              |
| -------- | ------------------ |
| Email    | `demo@todoapp.com` |
| Password | `Demo@1234`        |

Or create your own account via **Sign Up**.

## Project Structure

```
lib/
├── main.dart                  — App entry point, global dark theme
├── screens/
│   ├── splash_screen.dart     — 2-second launch screen
│   ├── login_screen.dart      — Login with validation
│   ├── signup_screen.dart     — Registration with validation
│   ├── home_screen.dart       — To-do list (ListView + SharedPreferences)
│   └── counter_screen.dart    — Counter app (setState + SharedPreferences)
└── utils/
    ├── colors.dart            — Centralized dark-mode color palette
    ├── validators.dart        — Reusable form validators
    └── user_store.dart        — In-memory user registry
```

## Getting Started

1. Install Flutter — [flutter.dev](https://flutter.dev)
2. Clone the repository.
3. Run `flutter pub get` to fetch dependencies.
4. Connect a device or start an emulator.
5. Run `flutter run`.

## Key Packages

| Package              | Purpose                             |
| -------------------- | ----------------------------------- |
| `shared_preferences` | Persist tasks and counter locally   |
| `cupertino_icons`    | iOS-style icons                     |

## Learning Objectives Addressed

**Week 1**
- Understand Flutter's basic project structure.
- Build responsive UIs with Column, Row, Container, Form, TextFormField.
- Navigate between screens using `Navigator.push` / `pushReplacement` / `pop`.
- Validate forms (email format, password strength, required fields).

**Week 2**
- Manage widget state with `setState`.
- Persist and retrieve primitive values and structured data using `SharedPreferences`.
- Build a `ListView`-based to-do list with add, complete, and delete operations.
- Restore app state on restart using persisted JSON data.

