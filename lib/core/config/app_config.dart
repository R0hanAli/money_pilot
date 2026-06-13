import 'package:flutter/material.dart';

class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

class AppConfig {
  AppConfig._();

  static const String appName = 'Money Pilot';

  static const List<CurrencyInfo> currencies = [
    CurrencyInfo(code: 'USD', symbol: '\$', name: 'US Dollar'),
    CurrencyInfo(code: 'PKR', symbol: '₨', name: 'Pakistani Rupee'),
    CurrencyInfo(code: 'EUR', symbol: '€', name: 'Euro'),
    CurrencyInfo(code: 'GBP', symbol: '£', name: 'British Pound'),
    CurrencyInfo(code: 'AED', symbol: 'د.إ', name: 'UAE Dirham'),
    CurrencyInfo(code: 'SAR', symbol: '﷼', name: 'Saudi Riyal'),
  ];

  static const List<String> expenseCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Education',
    'Health',
    'Travel',
    'Others',
  ];

  static const List<String> incomeSources = [
    'Salary',
    'Freelancing',
    'Business',
    'Investments',
    'Gift',
    'Other',
  ];

  static const List<String> paymentMethods = [
    'Cash',
    'Debit Card',
    'Credit Card',
    'Bank Transfer',
    'Mobile Wallet',
  ];

  static const Map<String, IconData> categoryIcons = {
    'Food': Icons.restaurant_rounded,
    'Transport': Icons.directions_car_rounded,
    'Shopping': Icons.shopping_bag_rounded,
    'Bills': Icons.receipt_long_rounded,
    'Entertainment': Icons.movie_rounded,
    'Education': Icons.school_rounded,
    'Health': Icons.favorite_rounded,
    'Travel': Icons.flight_rounded,
    'Others': Icons.more_horiz_rounded,
    'Salary': Icons.work_rounded,
    'Freelancing': Icons.laptop_rounded,
    'Business': Icons.business_center_rounded,
    'Investments': Icons.trending_up_rounded,
    'Gift': Icons.card_giftcard_rounded,
    'Other': Icons.attach_money_rounded,
  };
}
