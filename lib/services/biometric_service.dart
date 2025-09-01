import 'dart:io';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final _auth = LocalAuthentication();

  /// Checks if biometrics or device authentication is available
  Future<bool> canCheck() async {
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      try {
        final bool canCheckBiometrics = await _auth.canCheckBiometrics;
        final bool isDeviceSupported = await _auth.isDeviceSupported();
        return canCheckBiometrics || isDeviceSupported;
      } catch (_) {
        return false;
      }
    }
    return false; // Windows/Linux/Web not supported reliably
  }

  /// Prompts the user for biometric authentication
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Authenticate to unlock your vault',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true, // keeps the session active if user switches apps
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
