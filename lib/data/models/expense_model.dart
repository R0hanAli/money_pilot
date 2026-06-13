import 'package:uuid/uuid.dart';

class ExpenseModel {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final String paymentMethod;
  final String description;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseModel({
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

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      paymentMethod: map['paymentMethod'] as String,
      description: map['description'] as String? ?? '',
      transactionDate: DateTime.parse(map['transactionDate'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'category': category,
      'paymentMethod': paymentMethod,
      'description': description,
      'transactionDate': transactionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ExpenseModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ExpenseModel(
      id: id,
      userId: data['userId'] as String,
      amount: (data['amount'] as num).toDouble(),
      category: data['category'] as String,
      paymentMethod: data['paymentMethod'] as String,
      description: data['description'] as String? ?? '',
      transactionDate: DateTime.parse(data['transactionDate'] as String),
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'category': category,
      'paymentMethod': paymentMethod,
      'description': description,
      'transactionDate': transactionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ExpenseModel copyWith({
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
    return ExpenseModel(
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

  factory ExpenseModel.create({
    required String userId,
    required double amount,
    required String category,
    required String paymentMethod,
    String description = '',
    required DateTime transactionDate,
  }) {
    final now = DateTime.now();
    return ExpenseModel(
      id: const Uuid().v4(),
      userId: userId,
      amount: amount,
      category: category,
      paymentMethod: paymentMethod,
      description: description,
      transactionDate: transactionDate,
      createdAt: now,
      updatedAt: now,
    );
  }
}
