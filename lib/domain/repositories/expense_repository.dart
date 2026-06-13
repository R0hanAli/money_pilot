import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseEntity>> getExpenses(String userId);
  Future<List<ExpenseEntity>> getExpensesByMonth(String userId, String month);
  Future<List<ExpenseEntity>> getExpensesByCategory(
      String userId, String category);
  Future<ExpenseEntity?> getExpenseById(String id);
  Future<void> addExpense(ExpenseEntity expense);
  Future<void> updateExpense(ExpenseEntity expense);
  Future<void> deleteExpense(String id);
  Future<double> getTotalExpenseForMonth(String userId, String month);
}
