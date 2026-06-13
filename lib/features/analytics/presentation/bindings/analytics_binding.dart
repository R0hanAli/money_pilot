import 'package:get/get.dart';
import 'package:money_pilot/features/analytics/presentation/controllers/analytics_controller.dart';

class AnalyticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnalyticsController>(
      () => AnalyticsController(),
      fenix: true,
    );
  }
}
