import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';
import '../models/income_model.dart';
import '../models/budget_model.dart';
import '../models/category_budget_model.dart';
import '../models/user_model.dart';

class FirestoreDataSource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _usersCollection = 'users';
  static const String _expensesCollection = 'expenses';
  static const String _incomeCollection = 'income';
  static const String _budgetsCollection = 'budgets';
  static const String _categoryBudgetsCollection = 'category_budgets';

  Future<void> saveUser(UserModel user) async {
    try {
      await _db
          .collection(_usersCollection)
          .doc(user.id)
          .set(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to save user to Firestore: $e');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc =
          await _db.collection(_usersCollection).doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to fetch user from Firestore: $e');
    }
  }

  Future<void> saveExpense(ExpenseModel expense) async {
    try {
      await _db
          .collection(_expensesCollection)
          .doc(expense.id)
          .set(expense.toFirestore());
    } catch (e) {
      throw Exception('Failed to save expense to Firestore: $e');
    }
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await _db
          .collection(_expensesCollection)
          .doc(expense.id)
          .update(expense.toFirestore());
    } catch (e) {
      throw Exception('Failed to update expense in Firestore: $e');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _db.collection(_expensesCollection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete expense from Firestore: $e');
    }
  }

  Future<List<ExpenseModel>> getUserExpenses(String userId) async {
    try {
      final snapshot = await _db
          .collection(_expensesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('transactionDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch expenses from Firestore: $e');
    }
  }

  Future<void> saveIncome(IncomeModel income) async {
    try {
      await _db
          .collection(_incomeCollection)
          .doc(income.id)
          .set(income.toFirestore());
    } catch (e) {
      throw Exception('Failed to save income to Firestore: $e');
    }
  }

  Future<void> updateIncome(IncomeModel income) async {
    try {
      await _db
          .collection(_incomeCollection)
          .doc(income.id)
          .update(income.toFirestore());
    } catch (e) {
      throw Exception('Failed to update income in Firestore: $e');
    }
  }

  Future<void> deleteIncome(String id) async {
    try {
      await _db.collection(_incomeCollection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete income from Firestore: $e');
    }
  }

  Future<List<IncomeModel>> getUserIncome(String userId) async {
    try {
      final snapshot = await _db
          .collection(_incomeCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('transactionDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => IncomeModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch income from Firestore: $e');
    }
  }

  Future<void> saveBudget(BudgetModel budget) async {
    try {
      await _db
          .collection(_budgetsCollection)
          .doc(budget.id)
          .set(budget.toFirestore());
    } catch (e) {
      throw Exception('Failed to save budget to Firestore: $e');
    }
  }

  Future<void> updateBudget(BudgetModel budget) async {
    try {
      await _db
          .collection(_budgetsCollection)
          .doc(budget.id)
          .update(budget.toFirestore());
    } catch (e) {
      throw Exception('Failed to update budget in Firestore: $e');
    }
  }

  Future<void> saveCategoryBudget(CategoryBudgetModel cb) async {
    try {
      await _db
          .collection(_categoryBudgetsCollection)
          .doc(cb.id)
          .set(cb.toFirestore());
    } catch (e) {
      throw Exception('Failed to save category budget to Firestore: $e');
    }
  }
}
