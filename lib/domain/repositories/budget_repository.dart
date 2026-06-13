import '../entities/budget_entity.dart';
import '../entities/category_budget_entity.dart';

abstract class BudgetRepository {
  Future<BudgetEntity?> getBudget(String userId, String month);
  Future<void> setBudget(BudgetEntity budget);
  Future<void> updateBudgetUsage(
      String userId, String month, double usedAmount);
  Future<List<CategoryBudgetEntity>> getCategoryBudgets(
      String userId, String month);
  Future<void> setCategoryBudget(CategoryBudgetEntity cb);
  Future<void> updateCategorySpent(
      String userId, String month, String category, double spentAmount);
}
