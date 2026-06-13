class CategoryBudgetEntity {
  final String id;
  final String userId;
  final String month;
  final String category;
  final double allocatedAmount;
  final double spentAmount;

  const CategoryBudgetEntity({
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

  CategoryBudgetEntity copyWith({
    String? id,
    String? userId,
    String? month,
    String? category,
    double? allocatedAmount,
    double? spentAmount,
  }) {
    return CategoryBudgetEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      month: month ?? this.month,
      category: category ?? this.category,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
    );
  }
}
