import 'package:get/get.dart';
import 'package:money_pilot/core/utils/date_formatter.dart';
import 'package:money_pilot/domain/entities/income_entity.dart';
import 'package:money_pilot/domain/repositories/auth_repository.dart';
import 'package:money_pilot/domain/repositories/income_repository.dart';

class IncomeController extends GetxController {
  final _incomeRepo = Get.find<IncomeRepository>();
  final _authRepo = Get.find<AuthRepository>();

  final RxList<IncomeEntity> incomes = <IncomeEntity>[].obs;
  final RxList<IncomeEntity> filtered = <IncomeEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedSource = 'All'.obs;
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxString searchQuery = ''.obs;

  String get userId => _authRepo.currentUserId ?? '';
  String get currentMonth => DateFormatter.formatMonthKey(DateTime.now());

  @override
  void onInit() {
    super.onInit();
    loadIncomes();
  }

  Future<void> loadIncomes() async {
    if (userId.isEmpty) return;
    isLoading.value = true;
    try {
      final result = await _incomeRepo.getIncome(userId);
      incomes.assignAll(result);
      applyFilters();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addIncome(IncomeEntity income) async {
    isLoading.value = true;
    try {
      await _incomeRepo.addIncome(income);
      await loadIncomes();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateIncome(IncomeEntity income) async {
    isLoading.value = true;
    try {
      await _incomeRepo.updateIncome(income);
      await loadIncomes();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteIncome(String id) async {
    isLoading.value = true;
    try {
      await _incomeRepo.deleteIncome(id);
      await loadIncomes();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    List<IncomeEntity> result = List.from(incomes);

    if (selectedSource.value != 'All') {
      result = result.where((i) => i.source == selectedSource.value).toList();
    }

    final start = startDate.value;
    if (start != null) {
      result = result
          .where((i) =>
              i.transactionDate.isAfter(start.subtract(const Duration(days: 1))))
          .toList();
    }

    final end = endDate.value;
    if (end != null) {
      result = result
          .where((i) => i.transactionDate.isBefore(end.add(const Duration(days: 1))))
          .toList();
    }

    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where((i) =>
              i.notes.toLowerCase().contains(query) ||
              i.source.toLowerCase().contains(query))
          .toList();
    }

    filtered.assignAll(result);
  }

  void clearFilters() {
    selectedSource.value = 'All';
    startDate.value = null;
    endDate.value = null;
    searchQuery.value = '';
    applyFilters();
  }

  double get totalFiltered => filtered.fold(0.0, (sum, i) => sum + i.amount);
}
