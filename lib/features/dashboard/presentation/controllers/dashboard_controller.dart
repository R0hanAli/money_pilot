import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_pilot/core/services/notification_service.dart';
import 'package:money_pilot/core/utils/date_formatter.dart';
import 'package:money_pilot/domain/entities/budget_entity.dart';
import 'package:money_pilot/domain/entities/category_budget_entity.dart';
import 'package:money_pilot/domain/entities/expense_entity.dart';
import 'package:money_pilot/domain/entities/income_entity.dart';
import 'package:money_pilot/domain/repositories/auth_repository.dart';
import 'package:money_pilot/domain/repositories/budget_repository.dart';
import 'package:money_pilot/domain/repositories/expense_repository.dart';
import 'package:money_pilot/domain/repositories/income_repository.dart';

class DashboardController extends GetxController {
  late final ExpenseRepository _expenseRepo;
  late final IncomeRepository _incomeRepo;
  late final BudgetRepository _budgetRepo;
  late final AuthRepository _authRepo;

  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;
  final RxDouble totalSavings = 0.0.obs;
  final RxList<ExpenseEntity> recentExpenses = <ExpenseEntity>[].obs;
  final RxList<IncomeEntity> recentIncome = <IncomeEntity>[].obs;
  final Rx<BudgetEntity?> currentBudget = Rx<BudgetEntity?>(null);
  final RxList<CategoryBudgetEntity> categoryBudgets =
      <CategoryBudgetEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCurrency = 'USD'.obs;

  String get userId => _authRepo.currentUserId ?? '';

  String get currentMonth => DateFormatter.formatMonthKey(DateTime.now());

  @override
  void onInit() {
    super.onInit();
    _expenseRepo = Get.find<ExpenseRepository>();
    _incomeRepo = Get.find<IncomeRepository>();
    _budgetRepo = Get.find<BudgetRepository>();
    _authRepo = Get.find<AuthRepository>();
    _loadCurrency();
    loadDashboard();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    selectedCurrency.value = prefs.getString('currency') ?? 'USD';
  }

  Future<void> loadDashboard() async {
    if (userId.isEmpty) return;
    isLoading.value = true;
    try {
      await Future.wait([
        _loadExpenses(),
        _loadIncome(),
        _loadBudget(),
        _loadCategoryBudgets(),
      ]);
      _updateSavings();
      await _checkBudgetWarnings();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() async {
    await loadDashboard();
  }

  Future<void> _loadExpenses() async {
    final expenses =
        await _expenseRepo.getExpensesByMonth(userId, currentMonth);
    recentExpenses.value = expenses.take(5).toList();
    totalExpense.value = expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  Future<void> _loadIncome() async {
    final incomes = await _incomeRepo.getIncomeByMonth(userId, currentMonth);
    recentIncome.value = incomes.take(5).toList();
    totalIncome.value = incomes.fold(0.0, (sum, i) => sum + i.amount);
  }

  Future<void> _loadBudget() async {
    currentBudget.value = await _budgetRepo.getBudget(userId, currentMonth);
  }

  Future<void> _loadCategoryBudgets() async {
    categoryBudgets.value =
        await _budgetRepo.getCategoryBudgets(userId, currentMonth);
  }

  void _updateSavings() {
    totalSavings.value = totalIncome.value - totalExpense.value;
  }

  Future<void> _checkBudgetWarnings() async {
    final budget = currentBudget.value;
    if (budget == null) return;

    final percentage = budget.usagePercentage;
    if (percentage >= 100) {
      await NotificationService.instance
          .showBudgetExceeded('Monthly Budget');
    } else if (percentage >= 80) {
      await NotificationService.instance
          .showBudgetWarning('Monthly Budget', percentage);
    }

    for (final cb in categoryBudgets) {
      final catPct = cb.spentPercentage;
      if (catPct >= 100) {
        await NotificationService.instance.showBudgetExceeded(cb.category);
      } else if (catPct >= 80) {
        await NotificationService.instance
            .showBudgetWarning(cb.category, catPct);
      }
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _expenseRepo.deleteExpense(id);
      await loadDashboard();
    } catch (_) {}
  }

  Future<void> deleteIncome(String id) async {
    try {
      await _incomeRepo.deleteIncome(id);
      await loadDashboard();
    } catch (_) {}
  }
}
