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
