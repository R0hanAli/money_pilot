import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:money_pilot/core/utils/date_formatter.dart';
import 'package:money_pilot/domain/entities/budget_entity.dart';
import 'package:money_pilot/domain/entities/category_budget_entity.dart';
import 'package:money_pilot/domain/repositories/auth_repository.dart';
import 'package:money_pilot/domain/repositories/budget_repository.dart';

class BudgetController extends GetxController {
  final _budgetRepo = Get.find<BudgetRepository>();
  final _authRepo = Get.find<AuthRepository>();

  final Rx<BudgetEntity?> currentBudget = Rx<BudgetEntity?>(null);
  final RxList<CategoryBudgetEntity> categoryBudgets = <CategoryBudgetEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCurrency = 'USD'.obs;

  String get userId => _authRepo.currentUserId ?? '';
  String get currentMonth => DateFormatter.formatMonthKey(DateTime.now());

  @override
  void onInit() {
    super.onInit();
    _loadCurrency();
    loadBudgets();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    selectedCurrency.value = prefs.getString('currency') ?? 'USD';
  }

  Future<void> loadBudgets() async {
    if (userId.isEmpty) return;
    isLoading.value = true;
    try {
      currentBudget.value = await _budgetRepo.getBudget(userId, currentMonth);
      final list = await _budgetRepo.getCategoryBudgets(userId, currentMonth);
      categoryBudgets.assignAll(list);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setMonthlyBudget(double amount) async {
    if (userId.isEmpty) return;
    isLoading.value = true;
    try {
      final now = DateTime.now();
      final existing = currentBudget.value;
      
      final budget = BudgetEntity(
        id: existing?.id ?? const Uuid().v4(),
        userId: userId,
        month: currentMonth,
        totalBudget: amount,
        remainingBudget: amount - (existing?.usedBudget ?? 0.0),
        usedBudget: existing?.usedBudget ?? 0.0,
        createdAt: existing?.createdAt ?? now,
      );

      await _budgetRepo.setBudget(budget);
      await loadBudgets();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setCategoryBudget(String category, double amount) async {
    if (userId.isEmpty) return;
    isLoading.value = true;
    try {
      final existing = categoryBudgets.firstWhereOrNull((cb) => cb.category == category);
      
      final cb = CategoryBudgetEntity(
        id: existing?.id ?? const Uuid().v4(),
        userId: userId,
        month: currentMonth,
        category: category,
        allocatedAmount: amount,
        spentAmount: existing?.spentAmount ?? 0.0,
      );

      await _budgetRepo.setCategoryBudget(cb);
      await loadBudgets();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }
}
