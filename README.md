# Expenzia 💸

A production-quality **expense management** Flutter application built with SQLite, Provider, and clean architecture.

---

## Features

- 📊 **Dashboard** — Real-time total balance, income, expenses, daily average & weekly summary
- ➕ **Add Transaction** — Create income or expense entries with category, amount, and date
- ✏️ **Edit Transaction** — Update existing transactions; changes reflect immediately
- 🗑️ **Delete Transaction** — Remove transactions with confirmation dialog
- 📋 **Transaction History** — Full grouped-by-date transaction list
- 💾 **Persistent Storage** — SQLite database via `sqflite`; data survives app restarts
- 🔄 **Instant Refresh** — Home screen and history list update automatically after any change

---

## Prerequisites

Make sure the following are installed and working on your machine before proceeding.

| Tool | Minimum version | Check |
|---|---|---|
| Flutter SDK | `3.5.0` | `flutter --version` |
| Dart SDK | `3.5.0` (bundled with Flutter) | `dart --version` |
| Android Studio / Xcode | Latest stable | For emulator / device |
| A connected device or emulator | Android or iOS | `flutter devices` |

> **Tip:** Run `flutter doctor` to check your environment for any missing dependencies.

---

## Getting Started

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd expenzia
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Verify the setup

```bash
flutter doctor
flutter devices
```

Make sure at least one device or emulator appears in `flutter devices`.

### 4. Run the app

```bash
flutter run
```

To run on a specific device:

```bash
# List available devices first
flutter devices

# Run on a specific device by its ID
flutter run -d <device-id>

# Examples:
flutter run -d emulator-5554          # Android emulator
flutter run -d 00008110-001234567890  # iPhone (physical)
```

### 5. Run in release mode (optional)

```bash
flutter run --release
```

---

## Build

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

### iOS (macOS only)

```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode to archive and distribute.

---

## Project Structure

```
lib/
├── core/                         # Shared utilities and constants
│   ├── constants/
│   │   ├── app_colors.dart       # Color palette
│   │   └── app_strings.dart      # All string constants, categories, DB column names
│   ├── utils/
│   │   ├── formatters.dart       # Currency, date formatters
│   │   └── validators.dart       # Form validation logic
│   └── widgets/                  # Shared reusable widgets (loading, error, empty state)
│
├── data/                         # Data layer
│   ├── database/
│   │   └── app_database.dart     # SQLite database initialization & singleton
│   ├── models/
│   │   └── expense_model.dart    # SQLite serialization/deserialization model
│   └── repositories/
│       └── expense_repository_impl.dart  # Concrete SQLite repository implementation
│
├── domain/                       # Domain layer (business logic)
│   ├── entities/
│   │   └── expense.dart          # Core Expense entity
│   └── repositories/
│       └── expense_repository.dart       # Abstract repository interface
│
├── presentation/                 # UI layer
│   ├── providers/
│   │   └── expense_provider.dart # ChangeNotifier state management
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── dashboard_screen.dart         # Home screen
│   │   ├── add_expense_screen.dart       # Add transaction form
│   │   ├── edit_expense_screen.dart      # Edit transaction form
│   │   ├── transaction_history_screen.dart
│   │   └── profile_screen.dart
│   └── widgets/                  # Screen-specific reusable widgets
│
└── main.dart                     # App entry point, Provider setup
```

---

## Architecture

The app follows **Clean Architecture** with three layers:

```
Presentation  →  Domain  →  Data
(UI/Provider)    (Entities/   (SQLite/
                  Interfaces)   Repository impl)
```

- **Domain layer** defines the `Expense` entity and the abstract `ExpenseRepository` interface — no Flutter or SQLite dependencies.
- **Data layer** implements the repository using `sqflite` and maps between raw SQL rows and domain entities.
- **Presentation layer** uses a single `ExpenseProvider` (`ChangeNotifier`) consumed by `Consumer<ExpenseProvider>` widgets throughout the UI.

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `sqflite` | `^2.3.3` | Local SQLite database |
| `path` | `^1.9.0` | File path utilities for DB location |
| `provider` | `^6.1.2` | State management (`ChangeNotifier`) |
| `intl` | `^0.19.0` | Date & currency formatting |
| `cupertino_icons` | `^1.0.8` | iOS-style icons |

---

## Running Tests

```bash
flutter test
```

---

## Useful Commands

```bash
# Get all packages
flutter pub get

# Upgrade packages
flutter pub upgrade

# Analyze code for issues
flutter analyze

# Format all Dart files
dart format lib/

# Clean build cache
flutter clean && flutter pub get
```

---

## Troubleshooting

**`flutter run` fails with "No devices found"**
→ Start an Android emulator via Android Studio, or connect a physical device with USB debugging enabled, then run `flutter devices` to confirm it appears.

**Build fails after `flutter clean`**
→ Run `flutter pub get` again before `flutter run`.

**Database errors on first launch**
→ The SQLite database is created automatically on first run. If you see schema errors after upgrading, uninstall the app from the device/emulator and re-run.

**`sqflite` not working on desktop**
→ `sqflite` supports Android, iOS, and macOS. For Windows/Linux desktop targets, a different database package would be required. Run on Android or iOS for full functionality.
