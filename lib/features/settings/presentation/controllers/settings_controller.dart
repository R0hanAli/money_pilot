import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_pilot/core/services/notification_service.dart';
import 'package:money_pilot/domain/repositories/auth_repository.dart';
import 'package:money_pilot/features/auth/presentation/controllers/auth_controller.dart';

class SettingsController extends GetxController {
  final _authRepo = Get.find<AuthRepository>();

  final RxBool biometricEnabled = false.obs;
  final RxString selectedCurrency = 'USD'.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    biometricEnabled.value = prefs.getBool('biometric_enabled') ?? false;
    selectedCurrency.value = prefs.getString('currency') ?? 'USD';
    notificationsEnabled.value = prefs.getBool('notifications_enabled') ?? true;
  }

  Future<void> updateCurrency(String currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currencyCode);
    selectedCurrency.value = currencyCode;
  }

  Future<void> toggleBiometrics(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', val);
    biometricEnabled.value = val;

    if (val) {
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        final email = authController.currentUser.value?.email;
        final password = authController.currentPassword;
        if (email != null && password != null) {
          await prefs.setString('bio_email', email);
          await prefs.setString('bio_password', password);
        }
      }
    } else {
      await prefs.remove('bio_email');
      await prefs.remove('bio_password');
    }

    if (Get.isRegistered<AuthController>()) {
      final authController = Get.find<AuthController>();
      await authController.checkBiometricAvailability();
      final user = authController.currentUser.value;
      if (user != null) {
        try {
          final updatedUser = user.copyWith(biometricEnabled: val);
          await _authRepo.updateUserProfile(updatedUser);
          authController.currentUser.value = updatedUser;
        } catch (_) {}
      }
    }
  }

  Future<void> toggleNotifications(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', val);
    notificationsEnabled.value = val;
    if (val) {
      await NotificationService.instance.requestPermission();
    }
  }

  Future<void> updateProfileName(String fullName) async {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;
    if (user == null) return;
    isLoading.value = true;
    try {
      final updatedUser = user.copyWith(fullName: fullName);
      await _authRepo.updateUserProfile(updatedUser);
      authController.currentUser.value = updatedUser;
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }
}
