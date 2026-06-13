import 'package:get/get.dart';
import 'package:money_pilot/core/services/connectivity_service.dart';
import 'package:money_pilot/data/datasources/firestore_datasource.dart';
import 'package:money_pilot/data/datasources/local_database.dart';
import 'package:money_pilot/data/repositories/budget_repository_impl.dart';
import 'package:money_pilot/data/repositories/expense_repository_impl.dart';
import 'package:money_pilot/data/repositories/income_repository_impl.dart';
import 'package:money_pilot/domain/repositories/budget_repository.dart';
import 'package:money_pilot/domain/repositories/expense_repository.dart';
import 'package:money_pilot/domain/repositories/income_repository.dart';
import 'package:money_pilot/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:money_pilot/features/expense/presentation/controllers/expense_controller.dart';
import 'package:money_pilot/features/income/presentation/controllers/income_controller.dart';
import 'package:money_pilot/features/analytics/presentation/controllers/analytics_controller.dart';
import 'package:money_pilot/features/settings/presentation/controllers/settings_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ConnectivityService>()) {
      Get.lazyPut<ConnectivityService>(
        () => ConnectivityService(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<FirestoreDataSource>()) {
      Get.lazyPut<FirestoreDataSource>(
        () => FirestoreDataSource(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ExpenseRepository>()) {
      Get.lazyPut<ExpenseRepository>(
        () => ExpenseRepositoryImpl(
          localDatabase: LocalDatabase.instance,
          firestoreDataSource: Get.find<FirestoreDataSource>(),
          connectivityService: Get.find<ConnectivityService>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<IncomeRepository>()) {
      Get.lazyPut<IncomeRepository>(
        () => IncomeRepositoryImpl(
          localDatabase: LocalDatabase.instance,
          firestoreDataSource: Get.find<FirestoreDataSource>(),
          connectivityService: Get.find<ConnectivityService>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<BudgetRepository>()) {
      Get.lazyPut<BudgetRepository>(
        () => BudgetRepositoryImpl(
          localDatabase: LocalDatabase.instance,
          firestoreDataSource: Get.find<FirestoreDataSource>(),
          connectivityService: Get.find<ConnectivityService>(),
        ),
        fenix: true,
      );
    }

    Get.lazyPut<DashboardController>(
      () => DashboardController(),
      fenix: true,
    );

    if (!Get.isRegistered<ExpenseController>()) {
      Get.lazyPut<ExpenseController>(
        () => ExpenseController(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<IncomeController>()) {
      Get.lazyPut<IncomeController>(
        () => IncomeController(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<AnalyticsController>()) {
      Get.lazyPut<AnalyticsController>(
        () => AnalyticsController(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<SettingsController>()) {
      Get.lazyPut<SettingsController>(
        () => SettingsController(),
        fenix: true,
      );
    }
  }
}
