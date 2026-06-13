class ExpenseEntity {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final String paymentMethod;
  final String description;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.paymentMethod,
    required this.description,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  ExpenseEntity copyWith({
    String? id,
    String? userId,
    double? amount,
    String? category,
    String? paymentMethod,
    String? description,
    DateTime? transactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
