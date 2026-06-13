import 'package:get/get.dart';
import 'package:money_pilot/core/services/biometric_service.dart';
import 'package:money_pilot/domain/entities/user_entity.dart';
import 'package:money_pilot/domain/repositories/auth_repository.dart';
import 'package:money_pilot/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final _authRepo = Get.find<AuthRepository>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<UserEntity?> currentUser = Rx<UserEntity?>(null);
  final RxBool isBiometricAvailable = false.obs;
  final RxBool _isAuthenticated = false.obs;
  String? _currentPassword;

  SharedPreferences? _prefs;

  bool get isAuthenticated => _isAuthenticated.value;
  String? get currentPassword => _currentPassword;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _checkAuthState();
    await checkBiometricAvailability();
  }

  Future<void> _checkAuthState() async {
    try {
      final authenticated = _authRepo.isAuthenticated;
      if (authenticated) {
        final user = await _authRepo.getCurrentUser();
        currentUser.value = user;
        _isAuthenticated.value = true;
      }
    } catch (_) {
      _isAuthenticated.value = false;
    }
  }

  Future<void> checkBiometricAvailability() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    final biometricEnabled = _prefs?.getBool('biometric_enabled') ?? false;
    if (!biometricEnabled) {
      isBiometricAvailable.value = false;
      return;
    }
    final authenticated = _authRepo.isAuthenticated;
    final hasStoredCredentials = _prefs?.getString('bio_email') != null && _prefs?.getString('bio_password') != null;
    if (!authenticated && !hasStoredCredentials) {
      isBiometricAvailable.value = false;
      return;
    }
    final available = await BiometricService.instance.isAvailable();
    isBiometricAvailable.value = available;
  }

  Future<void> signIn(String email, String password) async {
    if (isLoading.value) return;
    clearError();
    isLoading.value = true;
    try {
      final user = await _authRepo.signIn(email, password);
      _currentPassword = password;
      currentUser.value = user;
      _isAuthenticated.value = true;
      if (_prefs?.getBool('biometric_enabled') ?? false) {
        await _prefs?.setString('bio_email', email);
        await _prefs?.setString('bio_password', password);
      }
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      errorMessage.value = _mapError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp(String email, String password, String fullName) async {
    if (isLoading.value) return;
    clearError();
    isLoading.value = true;
    try {
      final user = await _authRepo.signUp(email, password, fullName);
      _currentPassword = password;
      currentUser.value = user;
      _isAuthenticated.value = true;
      if (_prefs?.getBool('biometric_enabled') ?? false) {
        await _prefs?.setString('bio_email', email);
        await _prefs?.setString('bio_password', password);
      }
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      errorMessage.value = _mapError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    isLoading.value = true;
    try {
      await _authRepo.signOut();
      currentUser.value = null;
      _isAuthenticated.value = false;
      await checkBiometricAvailability();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      errorMessage.value = _mapError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> authenticateWithBiometric() async {
    clearError();
    try {
      final success = await BiometricService.instance.authenticate();
      if (success) {
        final authenticated = _authRepo.isAuthenticated;
        if (authenticated) {
          final user = await _authRepo.getCurrentUser();
          currentUser.value = user;
          _isAuthenticated.value = true;
          Get.offAllNamed(AppRoutes.dashboard);
        } else {
          final email = _prefs?.getString('bio_email');
          final password = _prefs?.getString('bio_password');
          if (email != null && password != null) {
            isLoading.value = true;
            try {
              final user = await _authRepo.signIn(email, password);
              _currentPassword = password;
              currentUser.value = user;
              _isAuthenticated.value = true;
              Get.offAllNamed(AppRoutes.dashboard);
            } catch (e) {
              errorMessage.value = _mapError(e.toString());
            } finally {
              isLoading.value = false;
            }
          } else {
            errorMessage.value = 'No saved credentials. Please sign in with password first.';
          }
        }
      } else {
        errorMessage.value = 'Biometric authentication failed.';
      }
    } catch (e) {
      errorMessage.value = _mapError(e.toString());
    }
  }

  void clearError() {
    errorMessage.value = '';
  }

  String _mapError(String raw) {
    if (raw.contains('user-not-found') ||
        raw.contains('wrong-password') ||
        raw.contains('invalid-credential')) {
      return 'Invalid email or password.';
    }
    if (raw.contains('email-already-in-use')) {
      return 'An account with this email already exists.';
    }
    if (raw.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters.';
    }
    if (raw.contains('network-request-failed')) {
      return 'Network error. Please check your connection.';
    }
    if (raw.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }
    return 'Something went wrong. Please try again.';
  }
}
