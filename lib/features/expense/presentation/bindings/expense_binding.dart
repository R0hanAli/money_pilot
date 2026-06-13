import 'package:get/get.dart';
import 'package:money_pilot/core/services/connectivity_service.dart';
import 'package:money_pilot/data/datasources/firestore_datasource.dart';
import 'package:money_pilot/data/datasources/local_database.dart';
import 'package:money_pilot/data/repositories/expense_repository_impl.dart';
import 'package:money_pilot/domain/repositories/budget_repository.dart';
import 'package:money_pilot/domain/repositories/expense_repository.dart';
import 'package:money_pilot/domain/repositories/auth_repository.dart';
import 'package:money_pilot/features/expense/presentation/controllers/expense_controller.dart';

class ExpenseBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ConnectivityService>()) {
      Get.lazyPut<ConnectivityService>(
        () => ConnectivityService(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ExpenseRepository>()) {
      Get.lazyPut<ExpenseRepository>(
        () => ExpenseRepositoryImpl(
          localDatabase: LocalDatabase.instance,
          firestoreDataSource: FirestoreDataSource(),
          connectivityService: Get.find<ConnectivityService>(),
        ),
        fenix: true,
      );
    }

    Get.lazyPut<ExpenseController>(
      () => ExpenseController(),
      fenix: true,
    );
  }
}
