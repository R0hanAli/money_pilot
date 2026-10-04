💰 Money Pilot

Money Pilot is a modern personal finance management application built with Flutter, designed to help users manage their income, expenses, budgets, and financial activity from a single platform.

The application combines offline-first local storage, cloud synchronization, biometric security, interactive financial analytics, multi-currency support, and professional PDF statement generation to provide a practical personal finance experience.

✨ Overview

Managing personal finances often involves tracking transactions across multiple places. Money Pilot brings these activities together into a structured mobile application.

Users can:

Record income and expenses

Organize transactions by category

Set monthly and category-based budgets

Monitor spending patterns

Analyze income and expenses through charts

Continue using the application without an internet connection

Synchronize data with Firebase when connectivity is restored

Protect the application with biometric authentication

Export financial statements as PDF documents

Display financial information in different currencies
🧩 Core Features

💸 Income & Expense Tracking

Record and manage day-to-day financial transactions.

Expenses

Add expenses

Assign expense categories

Track spending amounts

Review transaction history

Search and filter transactions

Income

Record income sources

Track incoming funds

Review income history

Compare income against expenses

📊 Financial Analytics

Money Pilot provides visual insights into personal finances using interactive charts.

Analytics can include:

Spending trends

Income trends

Expense distribution

Category-based spending

Inflow vs. outflow

Weekly summaries

Monthly financial activity

The application uses fl_chart to render interactive financial visualizations.

Income
  │
  ├── Salary
  ├── Business
  └── Other Income
          │
          ↓
     Total Income
          │
          ↓
      ┌─────────┐
      │ Balance │
      └─────────┘
          ↑
          │
      Total Expenses
          │
  ├── Food
  ├── Transport
  ├── Bills
  └── Other

🎯 Budget Management

Create spending limits to maintain better control over monthly finances.

Money Pilot supports:

Monthly spending limits

Category-specific limits

Budget usage tracking

Spending progress

Budget monitoring

Example:

Monthly Budget
      │
      ├── Food          → PKR 20,000
      ├── Transport     → PKR 10,000
      ├── Bills         → PKR 25,000
      └── Shopping      → PKR 15,000

This allows users to identify categories where spending is approaching or exceeding their configured limits.

📱 Offline-First Architecture

One of Money Pilot's core design goals is offline usability.

SQLite acts as the primary local data source, allowing users to access and modify their financial information even when there is no internet connection.

                    ┌──────────────┐
                    │ Flutter App  │
                    └──────┬───────┘
                           │
                           ↓
                    ┌──────────────┐
                    │    SQLite    │
                    │ Source of    │
                    │    Truth     │
                    └──────┬───────┘
                           │
                    Local Changes
                           │
                           ↓
                    ┌──────────────┐
                    │  Sync Queue  │
                    └──────┬───────┘
                           │
                    Internet Available
                           │
                           ↓
                    ┌──────────────┐
                    │   Firestore  │
                    └──────────────┘

Offline Workflow

User Action
    ↓
Save Locally
    ↓
SQLite Updated Immediately
    ↓
Add Operation to Sync Queue
    ↓
Connectivity Available?
    │
 ┌──┴───┐
 No     Yes
 │       │
 ↓       ↓
Wait   Sync
 │       │
 └───→ Firestore

This approach allows the application to remain useful even when network connectivity is unreliable.

☁️ Cloud Synchronization

Firebase Firestore provides remote synchronization for application data.

The synchronization system coordinates:

Local SQLite data

Pending synchronization operations

Connectivity state

Firestore updates

Local-to-cloud data consistency

When the device comes back online, queued operations can be synchronized with the remote database.

🔐 Biometric Authentication

Money Pilot supports local biometric authentication using local_auth.

Depending on device capabilities, users can authenticate using:

Fingerprint

Face authentication

Other supported biometric methods

The application is designed to provide graceful fallback behavior when biometric authentication is unavailable.

Biometric authentication is device-level protection and should be combined with appropriate application and data security practices.

📄 PDF Financial Statements

Money Pilot can generate professional PDF financial statements using the pdf and printing packages.

Generated reports can include:

Income transactions

Expense transactions

Transaction totals

Budget information

Budget usage

Financial summaries

Reporting periods

Analytical information

These reports can be printed or shared using supported platform functionality.

Financial Data
      ↓
Report Generation
      ↓
PDF Document
      ↓
Print / Share / Save

🌍 Multi-Currency Support

Money Pilot supports displaying financial information using multiple currency codes.

Supported currencies include:

Currency

Code

🇺🇸 US Dollar

USD

🇵🇰 Pakistani Rupee

PKR

🇪🇺 Euro

EUR

🇬🇧 British Pound

GBP

🇦🇪 UAE Dirham

AED

🇸🇦 Saudi Riyal

SAR

The application can switch the displayed currency according to the configured user preference.

🏗️ Architecture

Money Pilot follows a 3-layer Clean Architecture approach designed to separate business logic, data access, and presentation concerns.

┌─────────────────────────────────────┐
│            Presentation             │
│                                     │
│  Pages • Widgets • Controllers      │
│  Bindings • Navigation              │
└──────────────────┬──────────────────┘
                   │
                   ↓
┌─────────────────────────────────────┐
│               Domain                │
│                                     │
│  Entities • Repository Contracts    │
│  Business Rules                     │
└──────────────────┬──────────────────┘
                   │
                   ↓
┌─────────────────────────────────────┐
│                Data                 │
│                                     │
│  Models • Data Sources              │
│  SQLite • Firestore                 │
│  Repository Implementations         │
└─────────────────────────────────────┘

This structure helps keep the application's business logic independent from specific storage and UI implementations.

📁 Project Structure

lib/
│
├── core/
│   ├── configuration/
│   ├── services/
│   ├── theme/
│   └── utils/
│
├── domain/
│   ├── entities/
│   └── repositories/
│
├── data/
│   ├── models/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   └── repositories/
│
├── features/
│   ├── authentication/
│   ├── dashboard/
│   ├── expenses/
│   ├── income/
│   ├── budgets/
│   ├── analytics/
│   ├── transactions/
│   └── reports/
│
└── presentation/
    ├── navigation/
    └── widgets/

The exact folder structure may evolve as new modules are introduced.

🧠 Domain Layer

Located under:

lib/domain/

The domain layer contains the application's core business concepts and contracts.

Entities

Examples include:

UserEntity

ExpenseEntity

IncomeEntity

BudgetEntity

Transaction-related entities

Entities are designed to represent application data independently of external storage technologies.

Repository Contracts

Repository interfaces define the operations required by the business layer without depending directly on SQLite or Firestore.

Examples:

ExpenseRepository
IncomeRepository
BudgetRepository
AuthRepository

💾 Data Layer

Located under:

lib/data/

The data layer handles communication between the domain layer and external data sources.

Local Data

SQLite provides local persistence through sqflite.

Responsibilities include:

Database initialization

Table management

CRUD operations

Schema migrations

Pending synchronization operations

Local transaction storage

Remote Data

Firestore provides cloud synchronization.

Responsibilities include:

Remote document operations

Cloud synchronization

Remote data mapping

Synchronization of pending local operations

Models

Data models translate between storage representations and domain entities.

Typical serialization methods include:

fromMap()
toMap()

fromFirestore()
toFirestore()

🎨 Presentation Layer

The presentation layer is responsible for the application's user interface and interaction.

Money Pilot uses GetX for:

State management

Dependency injection

Navigation

Reactive UI updates

Controller lifecycle management

The interface follows a modern visual style using Outfit typography, clean layouts, animations, and financial dashboard components.

🛠️ Technology Stack

Technology

Purpose

Flutter

Cross-platform application framework

Dart

Programming language

GetX

State management, routing & dependency injection

SQLite / sqflite

Local database

Firebase Core

Firebase initialization

Firebase Auth

Authentication

Cloud Firestore

Cloud synchronization

fl_chart

Financial analytics

local_auth

Biometric authentication

flutter_local_notifications

Local notifications

pdf

PDF document generation

printing

PDF printing and sharing

🔄 Application Data Flow

                    Flutter UI
                       │
                       ↓
                  GetX Controller
                       │
                       ↓
                  Repository
                       │
             ┌─────────┴─────────┐
             ↓                   ↓
         SQLite              Firestore
             │                   │
             ↓                   ↓
       Local Source         Cloud Storage
             │
             ↓
        Sync Queue
             │
             ↓
       Connectivity
             │
             ↓
      Remote Synchronization

🚀 Setup & Installation

1. Prerequisites

Install Flutter and configure a development environment.

Verify your Flutter installation:

flutter doctor

Money Pilot requires a Flutter version compatible with the project's dependencies.

2. Clone the Repository

git clone <repository-url>

Navigate to the project:

cd money_pilot

3. Configure Firebase

Create a Firebase project and configure the required platforms.

Android

Place the Firebase configuration file at:

android/app/google-services.json

iOS

Place the Firebase configuration file at:

ios/Runner/GoogleService-Info.plist

Make sure the Firebase project is configured for the application package/bundle identifiers.

4. Install Dependencies

flutter pub get

5. Generate Launcher Icons

The application uses:

assets/images/logo.png

To regenerate launcher icons:

flutter pub run flutter_launcher_icons

6. Run the Application

flutter run

To run on a specific device:

flutter devices

Then:

flutter run -d <device-id>

🧪 Development & Testing

Analyze the project:

flutter analyze

Run tests:

flutter test

Format the project:

dart format .

Check available devices:

flutter devices

🔒 Security Considerations

Because Money Pilot handles financial information, security is an important part of the application design.

Recommended production practices include:

Never commit Firebase secrets or private credentials

Protect Firestore using appropriate security rules

Validate authenticated users before accessing financial records

Avoid storing unnecessary sensitive information

Protect local application access with authentication

Use secure communication for remote services

Validate synchronization operations

Maintain appropriate database backups

Keep third-party dependencies updated

🎯 Project Goals

Money Pilot aims to provide a practical personal finance solution that makes it easier to:

Understand spending habits

Track income and expenses

Maintain monthly budgets

Monitor financial progress

Work without continuous internet connectivity

Synchronize data across supported environments

Generate professional financial reports

Protect access to financial information

🔮 Future Improvements

Potential future enhancements include:

📈 Advanced financial forecasting

🔔 Budget limit notifications

📊 More detailed analytics

🔄 Improved conflict resolution for cloud synchronization

💳 Recurring transactions

📅 Recurring income and expenses

🎯 Savings goals

💰 Debt tracking

🏦 Bank account management

📤 CSV/Excel exports

📱 Improved tablet and desktop layouts

🌐 Additional currencies

🔐 Enhanced application security

☁️ Improved multi-device synchronization

📌 Project Status

Active Development

Money Pilot is a Flutter-based personal finance management project focused on combining modern UI design with practical financial management, offline-first storage, cloud synchronization, analytics, and reporting.

The architecture is designed to support continued development without tightly coupling business logic to the UI or database implementation.

👨‍💻 Author

Rohan Ali

Flutter & Mobile Application Developer

GitHub: R0hanAli

LinkedIn: Rohan Ali

📄 License

This project is maintained for development and educational purposes.

Add an appropriate open-source license if the repository is intended for public distribution.

💰 Money Pilot

Track your money. Understand your spending. Plan your future.
