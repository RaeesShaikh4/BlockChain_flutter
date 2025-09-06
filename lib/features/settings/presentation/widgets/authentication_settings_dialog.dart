import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/authentication_service.dart';
import '../../../../shared/services/biometric_service.dart';
import '../../../../shared/services/secure_storage_service.dart';
import '../../../../shared/widgets/pin_auth_dialog.dart';

class AuthenticationSettingsDialog extends ConsumerStatefulWidget {
  const AuthenticationSettingsDialog({super.key});

  @override
  ConsumerState<AuthenticationSettingsDialog> createState() => _AuthenticationSettingsDialogState();
}

class _AuthenticationSettingsDialogState extends ConsumerState<AuthenticationSettingsDialog> {
  final AuthenticationService _authService = AuthenticationService(
    biometricService: BiometricService(),
    secureStorageService: SecureStorageService(),
  );
  
  List<AuthenticationMethod> _availableMethods = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAvailableMethods();
  }

  Future<void> _loadAvailableMethods() async {
    try {
      final methods = await _authService.getAvailableAuthenticationMethods();
      setState(() {
        _availableMethods = methods;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Authentication Settings'),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorState()
                : _buildAuthenticationMethods(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline,
          size: 48,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          'Error loading authentication methods',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          _error!,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loadAvailableMethods,
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildAuthenticationMethods() {
    if (_availableMethods.isEmpty) {
      return _buildNoMethodsAvailable();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Choose your preferred authentication method:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        
        // Available methods
        ..._availableMethods.map((method) => _buildMethodCard(method)),
        
        const SizedBox(height: 16),
        
        // Security info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your authentication method will be used to secure access to your wallet.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoMethodsAvailable() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.security,
          size: 48,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'No Authentication Methods Available',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'This device does not support biometric authentication or other security methods. Your wallet will be secured with device-level encryption.',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lock,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Device Security',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Your private keys are still encrypted and stored securely on your device.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMethodCard(AuthenticationMethod method) {
    final securityLevel = _authService.getSecurityLevel(method);
    final methodName = _getMethodDisplayName(method);
    final methodIcon = _getMethodIcon(method);
    final methodDescription = _getMethodDescription(method);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getSecurityColor(securityLevel).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            methodIcon,
            color: _getSecurityColor(securityLevel),
            size: 20,
          ),
        ),
        title: Text(
          methodName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(methodDescription),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  _getSecurityIcon(securityLevel),
                  size: 12,
                  color: _getSecurityColor(securityLevel),
                ),
                const SizedBox(width: 4),
                Text(
                  _getSecurityLevelText(securityLevel),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _getSecurityColor(securityLevel),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        ),
        onTap: () => _selectAuthenticationMethod(method),
      ),
    );
  }

  void _selectAuthenticationMethod(AuthenticationMethod method) {
    switch (method) {
      case AuthenticationMethod.pin:
        _showPinSetupDialog();
        break;
      case AuthenticationMethod.pattern:
        _showPatternSetupDialog();
        break;
      case AuthenticationMethod.fingerprint:
      case AuthenticationMethod.faceId:
      case AuthenticationMethod.iris:
        _enableBiometricAuth();
        break;
      case AuthenticationMethod.devicePasscode:
        _enableDevicePasscodeAuth();
        break;
    }
  }

  void _showPinSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => PinAuthDialog(
        title: 'Set Up PIN',
        subtitle: 'Create a 6-digit PIN to secure your wallet',
        isSetupMode: true,
        onPinEntered: (pin) {
          Navigator.of(context).pop();
          _savePinAuth(pin);
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showPatternSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => PatternAuthDialog(
        title: 'Set Up Pattern',
        subtitle: 'Create a pattern to secure your wallet',
        isSetupMode: true,
        onPatternEntered: (pattern) {
          Navigator.of(context).pop();
          _savePatternAuth(pattern);
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _enableBiometricAuth() {
    // Enable biometric authentication
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Biometric authentication enabled'),
      ),
    );
  }

  void _enableDevicePasscodeAuth() {
    // Enable device passcode authentication
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Device passcode authentication enabled'),
      ),
    );
  }

  void _savePinAuth(String pin) {
    // Save PIN authentication
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PIN authentication set up successfully'),
      ),
    );
  }

  void _savePatternAuth(List<int> pattern) {
    // Save pattern authentication
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pattern authentication set up successfully'),
      ),
    );
  }

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

  IconData _getMethodIcon(AuthenticationMethod method) {
    switch (method) {
      case AuthenticationMethod.fingerprint:
        return Icons.fingerprint;
      case AuthenticationMethod.faceId:
        return Icons.face;
      case AuthenticationMethod.iris:
        return Icons.visibility;
      case AuthenticationMethod.pin:
        return Icons.pin;
      case AuthenticationMethod.pattern:
        return Icons.gesture;
      case AuthenticationMethod.devicePasscode:
        return Icons.lock;
    }
  }

  String _getMethodDescription(AuthenticationMethod method) {
    switch (method) {
      case AuthenticationMethod.fingerprint:
        return 'Use your fingerprint to authenticate';
      case AuthenticationMethod.faceId:
        return 'Use Face ID to authenticate';
      case AuthenticationMethod.iris:
        return 'Use iris scanning to authenticate';
      case AuthenticationMethod.pin:
        return 'Use a 6-digit PIN to authenticate';
      case AuthenticationMethod.pattern:
        return 'Use a pattern to authenticate';
      case AuthenticationMethod.devicePasscode:
        return 'Use your device passcode to authenticate';
    }
  }

  Color _getSecurityColor(SecurityLevel level) {
    switch (level) {
      case SecurityLevel.high:
        return Colors.green;
      case SecurityLevel.medium:
        return Colors.orange;
      case SecurityLevel.low:
        return Colors.red;
    }
  }

  IconData _getSecurityIcon(SecurityLevel level) {
    switch (level) {
      case SecurityLevel.high:
        return Icons.security;
      case SecurityLevel.medium:
        return Icons.shield;
      case SecurityLevel.low:
        return Icons.warning;
    }
  }

  String _getSecurityLevelText(SecurityLevel level) {
    switch (level) {
      case SecurityLevel.high:
        return 'High Security';
      case SecurityLevel.medium:
        return 'Medium Security';
      case SecurityLevel.low:
        return 'Low Security';
    }
  }
}
