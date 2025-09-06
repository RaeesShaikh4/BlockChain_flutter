import 'package:blockchain_flutter/shared/services/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/authentication_service.dart';
import '../services/biometric_service.dart';
import 'pin_auth_dialog.dart';

class AuthenticationFlow extends ConsumerStatefulWidget {
  final Widget child;
  final String? reason;
  final VoidCallback? onAuthenticationSuccess;
  final VoidCallback? onAuthenticationFailed;

  const AuthenticationFlow({
    super.key,
    required this.child,
    this.reason,
    this.onAuthenticationSuccess,
    this.onAuthenticationFailed,
  });

  @override
  ConsumerState<AuthenticationFlow> createState() => _AuthenticationFlowState();
}

class _AuthenticationFlowState extends ConsumerState<AuthenticationFlow> {
  final AuthenticationService _authService = AuthenticationService(
    biometricService: BiometricService(),
    secureStorageService: SecureStorageService(),
  );
  
  bool _isAuthenticated = false;
  bool _isLoading = true;
  List<AuthenticationMethod> _availableMethods = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationRequirement();
  }

  Future<void> _checkAuthenticationRequirement() async {
    try {
      final isRequired = await _authService.isAuthenticationRequired();
      
      if (!isRequired) {
        setState(() {
          _isAuthenticated = true;
          _isLoading = false;
        });
        return;
      }

      final methods = await _authService.getAvailableAuthenticationMethods();
      setState(() {
        _availableMethods = methods;
        _isLoading = false;
      });

      if (methods.isNotEmpty) {
        _showAuthenticationDialog();
      } else {
        // No authentication methods available - allow access with warning
        setState(() {
          _isAuthenticated = true;
        });
        _showNoAuthWarning();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showAuthenticationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AuthenticationDialog(
        availableMethods: _availableMethods,
        reason: widget.reason ?? 'Authenticate to access your wallet',
        onAuthenticated: () {
          Navigator.of(context).pop();
          setState(() {
            _isAuthenticated = true;
          });
          widget.onAuthenticationSuccess?.call();
        },
        onFailed: () {
          Navigator.of(context).pop();
          widget.onAuthenticationFailed?.call();
        },
        onSkip: () {
          Navigator.of(context).pop();
          setState(() {
            _isAuthenticated = true;
          });
          _showNoAuthWarning();
        },
      ),
    );
  }

  void _showNoAuthWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Access granted without authentication. Consider setting up security in settings.'),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: () {
            // Navigate to settings
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking authentication...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Authentication Error',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _checkAuthenticationRequirement,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isAuthenticated) {
      return widget.child;
    }

    return const Scaffold(
      body: Center(
        child: Text('Authentication required'),
      ),
    );
  }
}

class AuthenticationDialog extends StatefulWidget {
  final List<AuthenticationMethod> availableMethods;
  final String reason;
  final VoidCallback onAuthenticated;
  final VoidCallback onFailed;
  final VoidCallback onSkip;

  const AuthenticationDialog({
    super.key,
    required this.availableMethods,
    required this.reason,
    required this.onAuthenticated,
    required this.onFailed,
    required this.onSkip,
  });

  @override
  State<AuthenticationDialog> createState() => _AuthenticationDialogState();
}

class _AuthenticationDialogState extends State<AuthenticationDialog> {
  final AuthenticationService _authService = AuthenticationService(
    biometricService: BiometricService(),
    secureStorageService: SecureStorageService(),
  );
  
  bool _isAuthenticating = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Authenticate'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.reason,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Available methods
            ...widget.availableMethods.map((method) => _buildMethodButton(method)),
            
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onSkip,
          child: const Text('Skip'),
        ),
      ],
    );
  }

  Widget _buildMethodButton(AuthenticationMethod method) {
    final methodName = _getMethodDisplayName(method);
    final methodIcon = _getMethodIcon(method);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: _isAuthenticating ? null : () => _authenticate(method),
        icon: _isAuthenticating
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(methodIcon),
        label: Text(methodName),
      ),
    );
  }

  Future<void> _authenticate(AuthenticationMethod method) async {
    setState(() {
      _isAuthenticating = true;
      _error = null;
    });

    try {
      final result = await _authService.authenticate(
        reason: widget.reason,
        preferredMethod: method,
      );

      if (result.success) {
        widget.onAuthenticated();
      } else {
        setState(() {
          _error = result.error ?? 'Authentication failed';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  String _getMethodDisplayName(AuthenticationMethod method) {
    switch (method) {
      case AuthenticationMethod.fingerprint:
        return 'Use Fingerprint';
      case AuthenticationMethod.faceId:
        return 'Use Face ID';
      case AuthenticationMethod.iris:
        return 'Use Iris Scan';
      case AuthenticationMethod.pin:
        return 'Use PIN';
      case AuthenticationMethod.pattern:
        return 'Use Pattern';
      case AuthenticationMethod.devicePasscode:
        return 'Use Device Passcode';
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
}
