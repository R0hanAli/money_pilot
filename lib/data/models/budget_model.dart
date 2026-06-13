import 'package:uuid/uuid.dart';

class BudgetModel {
  final String id;
  final String userId;
  final String month;
  final double totalBudget;
  final double remainingBudget;
  final double usedBudget;
  final DateTime createdAt;

  const BudgetModel({
    required this.id,
    required this.userId,
    required this.month,
    required this.totalBudget,
    required this.remainingBudget,
    required this.usedBudget,
    required this.createdAt,
  });

  double get usagePercentage => totalBudget > 0 ? (usedBudget / totalBudget * 100) : 0;

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      month: map['month'] as String,
      totalBudget: (map['totalBudget'] as num).toDouble(),
      remainingBudget: (map['remainingBudget'] as num).toDouble(),
      usedBudget: (map['usedBudget'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'month': month,
      'totalBudget': totalBudget,
      'remainingBudget': remainingBudget,
      'usedBudget': usedBudget,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BudgetModel.fromFirestore(Map<String, dynamic> data, String id) {
    return BudgetModel(
      id: id,
      userId: data['userId'] as String,
      month: data['month'] as String,
      totalBudget: (data['totalBudget'] as num).toDouble(),
      remainingBudget: (data['remainingBudget'] as num).toDouble(),
      usedBudget: (data['usedBudget'] as num).toDouble(),
      createdAt: DateTime.parse(data['createdAt'] as String),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'month': month,
      'totalBudget': totalBudget,
      'remainingBudget': remainingBudget,
      'usedBudget': usedBudget,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  BudgetModel copyWith({
    String? id,
    String? userId,
    String? month,
    double? totalBudget,
    double? remainingBudget,
    double? usedBudget,
    DateTime? createdAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      month: month ?? this.month,
      totalBudget: totalBudget ?? this.totalBudget,
      remainingBudget: remainingBudget ?? this.remainingBudget,
      usedBudget: usedBudget ?? this.usedBudget,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory BudgetModel.create({
    required String userId,
    required String month,
    required double totalBudget,
  }) {
    return BudgetModel(
      id: const Uuid().v4(),
      userId: userId,
      month: month,
      totalBudget: totalBudget,
      remainingBudget: totalBudget,
      usedBudget: 0,
      createdAt: DateTime.now(),
    );
  }
}
