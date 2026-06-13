import 'package:get/get.dart';
import 'package:money_pilot/core/services/connectivity_service.dart';
import 'package:money_pilot/data/datasources/firestore_datasource.dart';
import 'package:money_pilot/data/datasources/local_database.dart';
import 'package:money_pilot/data/repositories/budget_repository_impl.dart';
import 'package:money_pilot/domain/repositories/budget_repository.dart';
import 'package:money_pilot/features/budget/presentation/controllers/budget_controller.dart';

class BudgetBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ConnectivityService>()) {
      Get.lazyPut<ConnectivityService>(
        () => ConnectivityService(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<BudgetRepository>()) {
      Get.lazyPut<BudgetRepository>(
        () => BudgetRepositoryImpl(
          localDatabase: LocalDatabase.instance,
          firestoreDataSource: FirestoreDataSource(),
          connectivityService: Get.find<ConnectivityService>(),
        ),
        fenix: true,
      );
    }

    Get.lazyPut<BudgetController>(
      () => BudgetController(),
      fenix: true,
    );
  }
}
