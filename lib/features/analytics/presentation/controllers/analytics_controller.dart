import 'package:get/get.dart';
import 'package:money_pilot/core/utils/date_formatter.dart';
import 'package:money_pilot/domain/entities/expense_entity.dart';
import 'package:money_pilot/domain/entities/income_entity.dart';
import 'package:money_pilot/domain/repositories/auth_repository.dart';
import 'package:money_pilot/domain/repositories/expense_repository.dart';
import 'package:money_pilot/domain/repositories/income_repository.dart';

class AnalyticsController extends GetxController {
  final _expenseRepo = Get.find<ExpenseRepository>();
  final _incomeRepo = Get.find<IncomeRepository>();
  final _authRepo = Get.find<AuthRepository>();

  final RxList<ExpenseEntity> monthlyExpenses = <ExpenseEntity>[].obs;
  final RxList<IncomeEntity> monthlyIncome = <IncomeEntity>[].obs;
  
  final RxMap<String, double> categoryBreakdown = <String, double>{}.obs;
  final RxList<double> weeklySpending = <double>[0, 0, 0, 0].obs;
  final RxList<double> monthlySpendingTrend = <double>[].obs;
  final RxList<String> trendMonths = <String>[].obs;
  
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;
  final RxBool isLoading = false.obs;

  String get userId => _authRepo.currentUserId ?? '';
  String get currentMonth => DateFormatter.formatMonthKey(DateTime.now());

  @override
  void onInit() {
    super.onInit();
    loadAnalyticsData();
  }

  Future<void> loadAnalyticsData() async {
    if (userId.isEmpty) return;
    isLoading.value = true;
    try {
      await Future.wait([
        _loadCurrentMonthData(),
        _loadTrendData(),
      ]);
      _computeCategoryBreakdown();
      _computeWeeklySpending();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadCurrentMonthData() async {
    final expenses = await _expenseRepo.getExpensesByMonth(userId, currentMonth);
    final incomes = await _incomeRepo.getIncomeByMonth(userId, currentMonth);

    monthlyExpenses.assignAll(expenses);
    monthlyIncome.assignAll(incomes);

    totalExpense.value = expenses.fold(0.0, (sum, e) => sum + e.amount);
    totalIncome.value = incomes.fold(0.0, (sum, i) => sum + i.amount);
  }

  Future<void> _loadTrendData() async {
    final now = DateTime.now();
    final List<double> trendValues = [];
    final List<String> trendNames = [];

    for (int i = 5; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      final monthKey = DateFormatter.formatMonthKey(targetDate);
      final total = await _expenseRepo.getTotalExpenseForMonth(userId, monthKey);
      
      trendValues.add(total);
      trendNames.add(DateFormatter.formatShort(targetDate).split(' ').last);
    }

    monthlySpendingTrend.assignAll(trendValues);
    trendMonths.assignAll(trendNames);
  }

  void _computeCategoryBreakdown() {
    final Map<String, double> breakdown = {};
    for (final e in monthlyExpenses) {
      breakdown[e.category] = (breakdown[e.category] ?? 0.0) + e.amount;
    }
    categoryBreakdown.assignAll(breakdown);
  }

  void _computeWeeklySpending() {
    final List<double> weeks = [0, 0, 0, 0];
    for (final e in monthlyExpenses) {
      final day = e.transactionDate.day;
      if (day <= 7) {
        weeks[0] += e.amount;
      } else if (day <= 14) {
        weeks[1] += e.amount;
      } else if (day <= 21) {
        weeks[2] += e.amount;
      } else {
        weeks[3] += e.amount;
      }
    }
    weeklySpending.assignAll(weeks);
  }
}
