class IncomeEntity {
  final String id;
  final String userId;
  final double amount;
  final String source;
  final String notes;
  final DateTime transactionDate;
  final DateTime createdAt;

  const IncomeEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.source,
    required this.notes,
    required this.transactionDate,
    required this.createdAt,
  });

  IncomeEntity copyWith({
    String? id,
    String? userId,
    double? amount,
    String? source,
    String? notes,
    DateTime? transactionDate,
    DateTime? createdAt,
  }) {
    return IncomeEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      source: source ?? this.source,
      notes: notes ?? this.notes,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
