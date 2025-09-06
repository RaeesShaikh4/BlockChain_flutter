import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';
import 'biometric_service.dart';
import 'secure_storage_service.dart';

class AuthenticationService {
  final BiometricService _biometricService;
  final SecureStorageService _secureStorageService;
  final Logger _logger = Logger();

  AuthenticationService({
    required BiometricService biometricService,
    required SecureStorageService secureStorageService,
  }) : _biometricService = biometricService,
       _secureStorageService = secureStorageService;

  /// Get available authentication methods for the current device
  Future<List<AuthenticationMethod>> getAvailableAuthenticationMethods() async {
    final methods = <AuthenticationMethod>[];
    
    try {
      // Check biometric availability
      final biometricAvailability = await _biometricService.checkBiometricAvailability();
      if (biometricAvailability == BiometricAvailability.available) {
        final biometricTypes = await _biometricService.getAvailableBiometricTypes();
        
        if (biometricTypes.contains(BiometricType.fingerprint)) {
          methods.add(AuthenticationMethod.fingerprint);
        }
        if (biometricTypes.contains(BiometricType.face)) {
          methods.add(AuthenticationMethod.faceId);
        }
        if (biometricTypes.contains(BiometricType.iris)) {
          methods.add(AuthenticationMethod.iris);
        }
      }

      // PIN/Password is always available as fallback
      methods.add(AuthenticationMethod.pin);
      
      // Pattern lock (Android specific)
      methods.add(AuthenticationMethod.pattern);
      
      _logger.i('Available authentication methods: $methods');
      return methods;
    } catch (e) {
      _logger.e('Error getting authentication methods: $e');
      // Return basic methods as fallback
      return [AuthenticationMethod.pin, AuthenticationMethod.pattern];
    }
  }

  /// Authenticate using the best available method
  Future<AuthenticationResult> authenticate({
    String reason = 'Authenticate to access your wallet',
    AuthenticationMethod? preferredMethod,
  }) async {
    try {
      final availableMethods = await getAvailableAuthenticationMethods();
      
      if (availableMethods.isEmpty) {
        return AuthenticationResult(
          success: false,
          error: 'No authentication methods available',
          method: null,
        );
      }

      // Use preferred method if available, otherwise use the first available
      final method = preferredMethod != null && availableMethods.contains(preferredMethod)
          ? preferredMethod
          : availableMethods.first;

      _logger.d('Authenticating using method: $method');

      switch (method) {
        case AuthenticationMethod.fingerprint:
        case AuthenticationMethod.faceId:
        case AuthenticationMethod.iris:
          return await _authenticateWithBiometric(method, reason);
        
        case AuthenticationMethod.pin:
          return await _authenticateWithPin(reason);
        
        case AuthenticationMethod.pattern:
          return await _authenticateWithPattern(reason);
        
        case AuthenticationMethod.devicePasscode:
          return await _authenticateWithDevicePasscode(reason);
      }
    } catch (e) {
      _logger.e('Authentication error: $e');
      return AuthenticationResult(
        success: false,
        error: 'Authentication failed: ${e.toString()}',
        method: null,
      );
    }
  }

  /// Authenticate with biometric
  Future<AuthenticationResult> _authenticateWithBiometric(
    AuthenticationMethod method,
    String reason,
  ) async {
    final result = await _biometricService.authenticate(reason: reason);
    
    return AuthenticationResult(
      success: result.success,
      error: result.error,
      method: method,
    );
  }

  /// Authenticate with PIN (custom implementation)
  Future<AuthenticationResult> _authenticateWithPin(String reason) async {
    // This would typically show a custom PIN input dialog
    // For now, we'll simulate a successful PIN authentication
    _logger.d('PIN authentication requested');
    
    // In a real implementation, you would:
    // 1. Show a PIN input dialog
    // 2. Verify the PIN against stored hash
    // 3. Return success/failure
    
    return AuthenticationResult(
      success: true, // Simulated success
      error: null,
      method: AuthenticationMethod.pin,
    );
  }

  /// Authenticate with pattern (Android specific)
  Future<AuthenticationResult> _authenticateWithPattern(String reason) async {
    // This would typically show a custom pattern input dialog
    _logger.d('Pattern authentication requested');
    
    return AuthenticationResult(
      success: true, // Simulated success
      error: null,
      method: AuthenticationMethod.pattern,
    );
  }

  /// Authenticate with device passcode
  Future<AuthenticationResult> _authenticateWithDevicePasscode(String reason) async {
    // Use biometric service with device passcode fallback
    final result = await _biometricService.authenticate(
      reason: reason,
    );
    
    return AuthenticationResult(
      success: result.success,
      error: result.error,
      method: AuthenticationMethod.devicePasscode,
    );
  }

  /// Check if authentication is required
  Future<bool> isAuthenticationRequired() async {
    try {
      final isBiometricEnabled = await _secureStorageService.isBiometricEnabled();
      return isBiometricEnabled;
    } catch (e) {
      _logger.e('Error checking authentication requirement: $e');
      return false;
    }
  }

  /// Get user-friendly message for available authentication methods
  String getAuthenticationMethodsMessage(List<AuthenticationMethod> methods) {
    if (methods.isEmpty) {
      return 'No authentication methods available on this device.';
    }

    final methodNames = methods.map((method) => _getMethodDisplayName(method)).join(', ');
    return 'Available authentication methods: $methodNames';
  }

  /// Get display name for authentication method
  String _getMethodDisplayName(AuthenticationMethod method) {
    switch (method) {
      case AuthenticationMethod.fingerprint:
        return 'Fingerprint';
      case AuthenticationMethod.faceId:
        return 'Face ID';
      case AuthenticationMethod.iris:
        return 'Iris Scan';
      case AuthenticationMethod.pin:
        return 'PIN';
      case AuthenticationMethod.pattern:
        return 'Pattern';
      case AuthenticationMethod.devicePasscode:
        return 'Device Passcode';
    }
  }

  /// Get security level for authentication method
  SecurityLevel getSecurityLevel(AuthenticationMethod method) {
    switch (method) {
      case AuthenticationMethod.fingerprint:
      case AuthenticationMethod.faceId:
      case AuthenticationMethod.iris:
        return SecurityLevel.high;
      case AuthenticationMethod.pin:
      case AuthenticationMethod.pattern:
        return SecurityLevel.medium;
      case AuthenticationMethod.devicePasscode:
        return SecurityLevel.medium;
    }
  }
}

enum AuthenticationMethod {
  fingerprint,
  faceId,
  iris,
  pin,
  pattern,
  devicePasscode,
}

enum SecurityLevel {
  low,
  medium,
  high,
}

class AuthenticationResult {
  final bool success;
  final String? error;
  final AuthenticationMethod? method;

  const AuthenticationResult({
    required this.success,
    this.error,
    this.method,
  });
}
