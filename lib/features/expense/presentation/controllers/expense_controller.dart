import 'package:get/get.dart';
import 'package:money_pilot/core/services/notification_service.dart';
import 'package:money_pilot/core/utils/date_formatter.dart';
import 'package:money_pilot/domain/entities/expense_entity.dart';
import 'package:money_pilot/domain/repositories/budget_repository.dart';
import 'package:money_pilot/domain/repositories/expense_repository.dart';
import 'package:money_pilot/domain/repositories/auth_repository.dart';

class ExpenseController extends GetxController {
  final _expenseRepo = Get.find<ExpenseRepository>();
  final _budgetRepo = Get.find<BudgetRepository>();
  final _authRepo = Get.find<AuthRepository>();

  final RxList<ExpenseEntity> expenses = <ExpenseEntity>[].obs;
  final RxList<ExpenseEntity> filtered = <ExpenseEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString selectedPaymentMethod = 'All'.obs;
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxString searchQuery = ''.obs;
  final Rx<ExpenseEntity?> selectedExpense = Rx<ExpenseEntity?>(null);

  String get currentMonth => DateFormatter.formatMonthKey(DateTime.now());

  @override
  void onInit() {
    super.onInit();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    final userId = _authRepo.currentUserId;
    if (userId == null) return;
    isLoading.value = true;
    try {
      final result = await _expenseRepo.getExpenses(userId);
      expenses.assignAll(result);
      applyFilters();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addExpense(ExpenseEntity expense) async {
    isLoading.value = true;
    try {
      await _expenseRepo.addExpense(expense);
      await _updateBudgetSpent(expense.userId);
      await loadExpenses();
      await _checkBudgetNotifications(expense);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateExpense(ExpenseEntity expense) async {
    isLoading.value = true;
    try {
      await _expenseRepo.updateExpense(expense);
      await _updateBudgetSpent(expense.userId);
      await loadExpenses();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteExpense(String id) async {
    isLoading.value = true;
    try {
      final userId = _authRepo.currentUserId;
      await _expenseRepo.deleteExpense(id);
      if (userId != null) {
        await _updateBudgetSpent(userId);
      }
      await loadExpenses();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    List<ExpenseEntity> result = List.from(expenses);

    if (selectedCategory.value != 'All') {
      result = result
          .where((e) => e.category == selectedCategory.value)
          .toList();
    }

    if (selectedPaymentMethod.value != 'All') {
      result = result
          .where((e) => e.paymentMethod == selectedPaymentMethod.value)
          .toList();
    }

    final start = startDate.value;
    if (start != null) {
      result = result
          .where((e) =>
              e.transactionDate.isAfter(start.subtract(const Duration(days: 1))))
          .toList();
    }

    final end = endDate.value;
    if (end != null) {
      result = result
          .where((e) => e.transactionDate
              .isBefore(end.add(const Duration(days: 1))))
          .toList();
    }

    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where((e) =>
              e.description.toLowerCase().contains(query) ||
              e.category.toLowerCase().contains(query))
          .toList();
    }

    filtered.assignAll(result);
  }

  void clearFilters() {
    selectedCategory.value = 'All';
    selectedPaymentMethod.value = 'All';
    startDate.value = null;
    endDate.value = null;
    searchQuery.value = '';
    applyFilters();
  }

  double get totalFiltered =>
      filtered.fold(0.0, (sum, e) => sum + e.amount);

  Future<void> _updateBudgetSpent(String userId) async {
    try {
      final month = currentMonth;
      final total = await _expenseRepo.getTotalExpenseForMonth(userId, month);
      await _budgetRepo.updateBudgetUsage(userId, month, total);
    } catch (_) {}
  }

  Future<void> _checkBudgetNotifications(ExpenseEntity expense) async {
    try {
      final userId = expense.userId;
      final month = currentMonth;
      final budget = await _budgetRepo.getBudget(userId, month);
      if (budget == null) return;

      final percentage = budget.usagePercentage;
      if (percentage >= 100) {
        await NotificationService.instance
            .showBudgetExceeded('Monthly Budget');
      } else if (percentage >= 80) {
        await NotificationService.instance
            .showBudgetWarning('Monthly Budget', percentage);
      }
    } catch (_) {}
  }
}
