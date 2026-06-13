import 'package:uuid/uuid.dart';

class IncomeModel {
  final String id;
  final String userId;
  final double amount;
  final String source;
  final String notes;
  final DateTime transactionDate;
  final DateTime createdAt;

  const IncomeModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.source,
    required this.notes,
    required this.transactionDate,
    required this.createdAt,
  });

  factory IncomeModel.fromMap(Map<String, dynamic> map) {
    return IncomeModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      amount: (map['amount'] as num).toDouble(),
      source: map['source'] as String,
      notes: map['notes'] as String? ?? '',
      transactionDate: DateTime.parse(map['transactionDate'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'source': source,
      'notes': notes,
      'transactionDate': transactionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory IncomeModel.fromFirestore(Map<String, dynamic> data, String id) {
    return IncomeModel(
      id: id,
      userId: data['userId'] as String,
      amount: (data['amount'] as num).toDouble(),
      source: data['source'] as String,
      notes: data['notes'] as String? ?? '',
      transactionDate: DateTime.parse(data['transactionDate'] as String),
      createdAt: DateTime.parse(data['createdAt'] as String),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'source': source,
      'notes': notes,
      'transactionDate': transactionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  IncomeModel copyWith({
    String? id,
    String? userId,
    double? amount,
    String? source,
    String? notes,
    DateTime? transactionDate,
    DateTime? createdAt,
  }) {
    return IncomeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      source: source ?? this.source,
      notes: notes ?? this.notes,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory IncomeModel.create({
    required String userId,
    required double amount,
    required String source,
    String notes = '',
    required DateTime transactionDate,
  }) {
    return IncomeModel(
      id: const Uuid().v4(),
      userId: userId,
      amount: amount,
      source: source,
      notes: notes,
      transactionDate: transactionDate,
      createdAt: DateTime.now(),
    );
  }
}
