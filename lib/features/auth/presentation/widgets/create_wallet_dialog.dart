import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/wallet_provider.dart';
import '../../../../shared/widgets/pin_auth_dialog.dart';
import '../../../../shared/services/authentication_service.dart';
import '../../../../shared/services/biometric_service.dart';
import '../../../../shared/services/secure_storage_service.dart';

class CreateWalletDialog extends ConsumerStatefulWidget {
  const CreateWalletDialog({super.key});

  @override
  ConsumerState<CreateWalletDialog> createState() => _CreateWalletDialogState();
}

class _CreateWalletDialogState extends ConsumerState<CreateWalletDialog> {
  bool _isCreating = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Wallet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          const Text(
            'This will create a new wallet with a new private key. Make sure to backup your private key securely.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.error.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Never share your private key with anyone!',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                ),
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
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createWallet,
          child: _isCreating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Wallet'),
        ),
      ],
    );
  }

  Future<void> _createWallet() async {
    setState(() {
      _isCreating = true;
      _error = null;
    });

    try {
      await ref.read(walletProvider.notifier).createWallet();
      
      if (mounted) {
        Navigator.of(context).pop();
        _showSecuritySetupDialog();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  void _showSecuritySetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Set Up Security'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.security,
              size: 48,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Protect your wallet with a PIN or biometric authentication.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showBackupDialog();
            },
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showPinSetupDialog();
            },
            child: const Text('Set Up PIN'),
          ),
        ],
      ),
    );
  }

  void _showPinSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PinAuthDialog(
        title: 'Set Up PIN',
        subtitle: 'Create a 6-digit PIN to secure your wallet',
        isSetupMode: true,
        onPinEntered: (pin) async {
          Navigator.of(context).pop();
          await _storePin(pin);
          _showBackupDialog();
        },
        onCancel: () {
          Navigator.of(context).pop();
          _showBackupDialog();
        },
      ),
    );
  }

  Future<void> _storePin(String pin) async {
    try {
      final authService = AuthenticationService(
        biometricService: BiometricService(),
        secureStorageService: SecureStorageService(),
      );
      await authService.storePin(pin);
    } catch (e) {
      // Handle error silently for now
      print('Failed to store PIN: $e');
    }
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Backup Your Wallet'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.backup,
              size: 48,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Your wallet has been created successfully! Please make sure to backup your private key in a secure location.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'You can export your private key from the wallet settings later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
