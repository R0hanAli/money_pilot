import 'package:get/get.dart';
import 'package:money_pilot/core/services/connectivity_service.dart';
import 'package:money_pilot/data/datasources/firestore_datasource.dart';
import 'package:money_pilot/data/datasources/local_database.dart';
import 'package:money_pilot/data/repositories/auth_repository_impl.dart';
import 'package:money_pilot/domain/repositories/auth_repository.dart';
import 'package:money_pilot/features/auth/presentation/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
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

    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(
        () => AuthRepositoryImpl(
          firestoreDataSource: Get.find<FirestoreDataSource>(),
          localDatabase: LocalDatabase.instance,
        ),
        fenix: true,
      );
    }

    Get.put<AuthController>(
      AuthController(),
      permanent: true,
    );
  }
}
