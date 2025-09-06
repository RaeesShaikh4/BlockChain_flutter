import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/wallet_provider.dart';

class ImportWalletDialog extends ConsumerStatefulWidget {
  const ImportWalletDialog({super.key});

  @override
  ConsumerState<ImportWalletDialog> createState() => _ImportWalletDialogState();
}

class _ImportWalletDialogState extends ConsumerState<ImportWalletDialog> {
  final _formKey = GlobalKey<FormState>();
  final _privateKeyController = TextEditingController();
  final _mnemonicController = TextEditingController();
  bool _isImporting = false;
  bool _isPrivateKeyMode = true;
  String? _error;

  @override
  void dispose() {
    _privateKeyController.dispose();
    _mnemonicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Wallet'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Import Mode Toggle
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isPrivateKeyMode = true;
                            _error = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isPrivateKeyMode
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Private Key',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _isPrivateKeyMode
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isPrivateKeyMode = false;
                            _error = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isPrivateKeyMode
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Mnemonic',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !_isPrivateKeyMode
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Input Field
              if (_isPrivateKeyMode) ...[
                TextFormField(
                  controller: _privateKeyController,
                  decoration: const InputDecoration(
                    labelText: 'Private Key',
                    hintText: 'Enter your private key (64 characters)',
                    prefixIcon: Icon(Icons.key),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your private key';
                    }
                    
                    // Remove 0x prefix if present
                    final cleanKey = value.startsWith('0x') 
                        ? value.substring(2) 
                        : value;
                    
                    if (cleanKey.length != 64) {
                      return 'Private key must be 64 characters long';
                    }
                    
                    // Check if it's valid hex
                    if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(cleanKey)) {
                      return 'Private key must contain only hexadecimal characters';
                    }
                    
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _error = null;
                    });
                  },
                ),
              ] else ...[
                TextFormField(
                  controller: _mnemonicController,
                  decoration: const InputDecoration(
                    labelText: 'Mnemonic Phrase',
                    hintText: 'Enter your 12 or 24 word mnemonic phrase',
                    prefixIcon: Icon(Icons.text_fields),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mnemonic phrase';
                    }
                    
                    final words = value.trim().split(RegExp(r'\s+'));
                    if (words.length != 12 && words.length != 24) {
                      return 'Mnemonic must be 12 or 24 words';
                    }
                    
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _error = null;
                    });
                  },
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Warning
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
                      Icons.warning_amber_rounded,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Never share your private key or mnemonic with anyone!',
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
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isImporting ? null : () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isImporting ? null : _importWallet,
          child: _isImporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Import Wallet'),
        ),
      ],
    );
  }

  Future<void> _importWallet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isImporting = true;
      _error = null;
    });

    try {
      if (_isPrivateKeyMode) {
        final privateKey = _privateKeyController.text.trim();
        await ref.read(walletProvider.notifier).importWallet(privateKey);
      } else {
        final mnemonic = _mnemonicController.text.trim();
        await ref.read(walletProvider.notifier).importWalletFromMnemonic(mnemonic);
      }
      
      if (mounted) {
        Navigator.of(context).pop();
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wallet Imported'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 48,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'Your wallet has been imported successfully!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
