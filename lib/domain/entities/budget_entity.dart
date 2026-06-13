class BudgetEntity {
  final String id;
  final String userId;
  final String month;
  final double totalBudget;
  final double remainingBudget;
  final double usedBudget;
  final DateTime createdAt;

  const BudgetEntity({
    required this.id,
    required this.userId,
    required this.month,
    required this.totalBudget,
    required this.remainingBudget,
    required this.usedBudget,
    required this.createdAt,
  });

  double get usagePercentage =>
      totalBudget > 0 ? (usedBudget / totalBudget * 100) : 0;

  BudgetEntity copyWith({
    String? id,
    String? userId,
    String? month,
    double? totalBudget,
    double? remainingBudget,
    double? usedBudget,
    DateTime? createdAt,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      month: month ?? this.month,
      totalBudget: totalBudget ?? this.totalBudget,
      remainingBudget: remainingBudget ?? this.remainingBudget,
      usedBudget: usedBudget ?? this.usedBudget,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
