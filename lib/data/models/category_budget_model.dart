import 'package:uuid/uuid.dart';

class CategoryBudgetModel {
  final String id;
  final String userId;
  final String month;
  final String category;
  final double allocatedAmount;
  final double spentAmount;

  const CategoryBudgetModel({
    required this.id,
    required this.userId,
    required this.month,
    required this.category,
    required this.allocatedAmount,
    required this.spentAmount,
  });

  double get spentPercentage =>
      allocatedAmount > 0 ? (spentAmount / allocatedAmount * 100) : 0;

  double get remainingAmount => allocatedAmount - spentAmount;

  factory CategoryBudgetModel.fromMap(Map<String, dynamic> map) {
    return CategoryBudgetModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      month: map['month'] as String,
      category: map['category'] as String,
      allocatedAmount: (map['allocatedAmount'] as num).toDouble(),
      spentAmount: (map['spentAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'month': month,
      'category': category,
      'allocatedAmount': allocatedAmount,
      'spentAmount': spentAmount,
    };
  }

  factory CategoryBudgetModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return CategoryBudgetModel(
      id: id,
      userId: data['userId'] as String,
      month: data['month'] as String,
      category: data['category'] as String,
      allocatedAmount: (data['allocatedAmount'] as num).toDouble(),
      spentAmount: (data['spentAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'month': month,
      'category': category,
      'allocatedAmount': allocatedAmount,
      'spentAmount': spentAmount,
    };
  }

  CategoryBudgetModel copyWith({
    String? id,
    String? userId,
    String? month,
    String? category,
    double? allocatedAmount,
    double? spentAmount,
  }) {
    return CategoryBudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      month: month ?? this.month,
      category: category ?? this.category,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
    );
  }

  factory CategoryBudgetModel.create({
    required String userId,
    required String month,
    required String category,
    required double allocatedAmount,
  }) {
    return CategoryBudgetModel(
      id: const Uuid().v4(),
      userId: userId,
      month: month,
      category: category,
      allocatedAmount: allocatedAmount,
      spentAmount: 0,
    );
  }
}
