import 'package:local_auth/local_auth.dart';

class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      final biometrics = await _auth.getAvailableBiometrics();

      return canCheck && isSupported && biometrics.isNotEmpty;
    } catch (e) {
      print("Availability error: $e");
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final available = await isAvailable();
      if (!available) return false;
      return await _auth.authenticate(
        localizedReason: 'Authenticate to access Money Pilot',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      print("Biometric error: $e");
      return false;
    }
  }
}
