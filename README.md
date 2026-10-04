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
