# Money Pilot

Money Pilot is a modern, premium personal finance management application built in Flutter. It empowers users to track expenses, log incomes, configure budget constraints, and analyze monthly cash flows through interactive analytics and professional PDF statement exports.

---

## Architecture Blueprint

Money Pilot adheres to a strict **3-Layer Clean Architecture** design pattern. This ensures a clean separation of concerns, testability, and independence from external libraries, frameworks, or databases.

```
lib/
├── core/               # App configuration, custom themes, services, and utility formatters
├── domain/             # Core business rules, immutable entities, and repository interfaces
├── data/               # SQLite tables, Firestore mappings, and repository implementations
├── features/           # Feature modules (UI controllers, bindings, screens, and custom widgets)
└── presentation/       # Shared navigation containers and global app bars
```

### 1. Domain Layer (`lib/domain/`)
The absolute core of the application logic. It contains pure Dart code with:
* **Entities**: Immutable blueprint data classes (e.g., `UserEntity`, `ExpenseEntity`, `BudgetEntity`).
* **Repositories**: Abstract contracts specifying data operations (e.g., `ExpenseRepository`, `AuthRepository`).

### 2. Data Layer (`lib/data/`)
Translates storage schemas and network feeds into clean domain entities:
* **Models**: Data classes extending domain entities with serialization methods (`fromMap`, `toMap`, `fromFirestore`, `toFirestore`).
* **Data Sources**:
  * `LocalDatabase`: SQLite helper (via `sqflite`) managing schemas, migrations, pending transaction sync queues, and CRUD executions.
  * `FirestoreDataSource`: Integrates and manages remote cloud synchronization.
* **Repository Implementations**: Coordinates local-first reads/writes, queuing sync operations when offline.

### 3. Presentation Layer (`lib/features/` & `lib/presentation/`)
Controls visual layout, gestures, animations, and component bindings:
* **Bindings**: Lazy dependency injections for repository implementations and controllers.
* **Controllers**: GetX reactive controllers managing states, lists, search filters, and page loadings.
* **Pages & Widgets**: Modern Flutter widgets styled using a premium Outfit typography theme with gradient styles and clean animations.

---

## Core Features

* **Offline-First Storage**: SQLite serves as the source of truth, enabling immediate loading and offline use.
* **Cloud Sync Queue**: An background synchronization worker observes connectivity status to upload local data queues to Firestore when online.
* **Biometric Authentication**: Local biometric locks (FaceID/Fingerprint) with graceful fallback behaviors.
* **Comprehensive Analytics**: Dynamic graphs using `fl_chart` illustrating spending trends, category distributions, inflow/outflow ratios, and weekly summaries.
* **Flexible Budgets**: Configurable monthly caps alongside itemized category limits (e.g. Food, Transport, Bills).
* **PDF Statement Exports**: Custom print drivers that compile transactions, budget limits, and usage progress charts into shareable PDF reports.
* **Currency Switcher**: Real-time conversion displaying values in currency codes (USD, PKR, EUR, GBP, AED, SAR).

---

## Technology Stack

* **State Management & DI**: GetX
* **Routing**: GetX Named Pages
* **Local Database**: SQLite (`sqflite`)
* **Backend Integration**: Firebase Core, Firestore, and FirebaseAuth
* **Analytics Rendering**: `fl_chart`
* **Secure Locks**: `local_auth`
* **Local Alerts**: `flutter_local_notifications`
* **PDF Engines**: `pdf` & `printing`

---

## Setup & Run Instructions

### 1. Prerequisites
Install the Flutter SDK (>= 3.5.0) and verify correct device simulator linkages.

### 2. Setup Firebase Configs
Create a Firebase project and add target configuration files:
* **Android**: Download `google-services.json` and place it under `android/app/`.
* **iOS**: Download `GoogleService-Info.plist` and place it under `ios/Runner/`.

### 3. Install Dependencies
Run the command below in the project root directory:
```bash
flutter pub get
```

### 4. Build Launcher Icons
Launcher icons have been generated from `assets/images/logo.png`. To rebuild icons at any time, run:
```bash
flutter pub run flutter_launcher_icons
```

### 5. Start the Application
Run the project in debug mode:
```bash
flutter run
```
