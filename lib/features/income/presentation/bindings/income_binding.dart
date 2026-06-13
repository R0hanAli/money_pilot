import 'package:get/get.dart';
import 'package:money_pilot/core/services/connectivity_service.dart';
import 'package:money_pilot/data/datasources/firestore_datasource.dart';
import 'package:money_pilot/data/datasources/local_database.dart';
import 'package:money_pilot/data/repositories/income_repository_impl.dart';
import 'package:money_pilot/domain/repositories/income_repository.dart';
import 'package:money_pilot/features/income/presentation/controllers/income_controller.dart';

class IncomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ConnectivityService>()) {
      Get.lazyPut<ConnectivityService>(
        () => ConnectivityService(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<IncomeRepository>()) {
      Get.lazyPut<IncomeRepository>(
        () => IncomeRepositoryImpl(
          localDatabase: LocalDatabase.instance,
          firestoreDataSource: FirestoreDataSource(),
          connectivityService: Get.find<ConnectivityService>(),
        ),
        fenix: true,
      );
    }

    Get.lazyPut<IncomeController>(
      () => IncomeController(),
      fenix: true,
    );
  }
}
