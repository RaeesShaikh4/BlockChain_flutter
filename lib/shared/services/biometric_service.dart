import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final Logger _logger = Logger();

  /// Check if biometric authentication is available on the device
  Future<BiometricAvailability> checkBiometricAvailability() async {
    try {
      _logger.d('Checking biometric availability');
      
      // Check if biometric authentication is available
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        _logger.w('Biometric authentication not available on this device');
        return BiometricAvailability.notAvailable;
      }

      // Check if device is enrolled (has biometrics set up)
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) {
        _logger.w('Device does not support biometric authentication');
        return BiometricAvailability.notSupported;
      }

      // Get available biometric types
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      if (availableBiometrics.isEmpty) {
        _logger.w('No biometrics enrolled on this device');
        return BiometricAvailability.notEnrolled;
      }

      _logger.i('Biometric authentication available: $availableBiometrics');
      return BiometricAvailability.available;
    } catch (e) {
      _logger.e('Error checking biometric availability: $e');
      return BiometricAvailability.error;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometricTypes() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics;
    } catch (e) {
      _logger.e('Error getting available biometric types: $e');
      return [];
    }
  }

  /// Authenticate using biometrics
  Future<BiometricResult> authenticate({
    String reason = 'Authenticate to access your wallet',
    String? cancelButton,
    String? goToSettingsButton,
    String? goToSettingsDescription,
  }) async {
    try {
      _logger.d('Starting biometric authentication');
      
      // Check availability first
      final availability = await checkBiometricAvailability();
      if (availability != BiometricAvailability.available) {
        return BiometricResult(
          success: false,
          error: _getAvailabilityErrorMessage(availability),
          biometricType: null,
        );
      }

      // Perform authentication
      final result = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // Allow device passcode as fallback
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );

      if (result) {
        final biometricTypes = await getAvailableBiometricTypes();
        _logger.i('Biometric authentication successful');
        return BiometricResult(
          success: true,
          error: null,
          biometricType: biometricTypes.isNotEmpty ? biometricTypes.first : null,
        );
      } else {
        _logger.w('Biometric authentication failed or cancelled');
        return BiometricResult(
          success: false,
          error: 'Authentication failed or cancelled',
          biometricType: null,
        );
      }
    } catch (e) {
      _logger.e('Error during biometric authentication: $e');
      return BiometricResult(
        success: false,
        error: 'Authentication error: ${e.toString()}',
        biometricType: null,
      );
    }
  }

  /// Check if biometric authentication should be used
  Future<bool> shouldUseBiometric() async {
    final availability = await checkBiometricAvailability();
    return availability == BiometricAvailability.available;
  }

  /// Get user-friendly message for biometric availability
  String getBiometricAvailabilityMessage() {
    return 'Biometric authentication is available on this device. '
           'You can enable it in settings for enhanced security.';
  }

  /// Get user-friendly message when biometric is not available
  String getBiometricUnavailableMessage() {
    return 'Biometric authentication is not available on this device. '
           'Your wallet will be secured with device-level encryption instead.';
  }

  String _getAvailabilityErrorMessage(BiometricAvailability availability) {
    switch (availability) {
      case BiometricAvailability.notAvailable:
        return 'Biometric authentication is not available on this device';
      case BiometricAvailability.notSupported:
        return 'This device does not support biometric authentication';
      case BiometricAvailability.notEnrolled:
        return 'No biometrics are enrolled on this device. Please set up biometric authentication in device settings';
      case BiometricAvailability.error:
        return 'Error checking biometric availability';
      case BiometricAvailability.available:
        return 'Biometric authentication is available';
    }
  }
}

enum BiometricAvailability {
  available,
  notAvailable,
  notSupported,
  notEnrolled,
  error,
}

class BiometricResult {
  final bool success;
  final String? error;
  final BiometricType? biometricType;

  const BiometricResult({
    required this.success,
    this.error,
    this.biometricType,
  });
}
