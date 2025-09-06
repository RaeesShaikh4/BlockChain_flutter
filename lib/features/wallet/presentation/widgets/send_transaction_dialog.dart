import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/wallet_provider.dart';

class SendTransactionDialog extends ConsumerStatefulWidget {
  const SendTransactionDialog({super.key});

  @override
  ConsumerState<SendTransactionDialog> createState() => _SendTransactionDialogState();
}

class _SendTransactionDialogState extends ConsumerState<SendTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _gasLimitController = TextEditingController();
  
  bool _isSending = false;
  String? _error;
  double _gasPrice = 0.0;
  int _gasLimit = 21000;

  @override
  void initState() {
    super.initState();
    _gasLimitController.text = _gasLimit.toString();
    _loadGasPrice();
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _gasLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    
    return AlertDialog(
      title: const Text('Send ETH'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Recipient Address
              TextFormField(
                controller: _recipientController,
                decoration: const InputDecoration(
                  labelText: 'Recipient Address',
                  hintText: '0x...',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter recipient address';
                  }
                  
                  // Basic address validation
                  if (!value.startsWith('0x') || value.length != 42) {
                    return 'Invalid Ethereum address';
                  }
                  
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _error = null;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (ETH)',
                  hintText: '0.0',
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: 'ETH',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  
                  if (amount > walletState.balance) {
                    return 'Insufficient balance';
                  }
                  
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _error = null;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Gas Settings
              ExpansionTile(
                title: const Text('Gas Settings'),
                children: [
                  TextFormField(
                    controller: _gasLimitController,
                    decoration: const InputDecoration(
                      labelText: 'Gas Limit',
                      hintText: '21000',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter gas limit';
                      }
                      
                      final limit = int.tryParse(value);
                      if (limit == null || limit <= 0) {
                        return 'Please enter a valid gas limit';
                      }
                      
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _gasLimit = int.tryParse(value) ?? 21000;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Gas Price Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Gas Price:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${_gasPrice.toStringAsFixed(2)} Gwei',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Transaction Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Amount:', '${_amountController.text} ETH'),
                    _buildSummaryRow('Gas Limit:', '$_gasLimit'),
                    _buildSummaryRow('Gas Price:', '${_gasPrice.toStringAsFixed(2)} Gwei'),
                    const Divider(),
                    _buildSummaryRow(
                      'Total Cost:',
                      '${_calculateTotalCost()} ETH',
                      isTotal: true,
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
          onPressed: _isSending ? null : () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSending ? null : _sendTransaction,
          child: _isSending
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send'),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTotalCost() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final gasCost = (_gasLimit * _gasPrice) / 1e9; // Convert Gwei to ETH
    final total = amount + gasCost;
    return total.toStringAsFixed(6);
  }

  Future<void> _loadGasPrice() async {
    try {
      // TODO: Load actual gas price from blockchain service
      setState(() {
        _gasPrice = 20.0; // Placeholder gas price in Gwei
      });
    } catch (e) {
      setState(() {
        _gasPrice = 20.0; // Fallback gas price
      });
    }
  }

  Future<void> _sendTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSending = true;
      _error = null;
    });

    try {
      final amount = double.parse(_amountController.text);
      final recipient = _recipientController.text.trim();
      
      final txHash = await ref.read(walletProvider.notifier).sendEth(
        toAddress: recipient,
        amount: amount,
        gasLimit: _gasLimit,
      );
      
      if (mounted && txHash != null) {
        Navigator.of(context).pop();
        _showSuccessDialog(txHash);
      } else {
        setState(() {
          _error = 'Transaction failed';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _showSuccessDialog(String txHash) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction Sent'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              size: 48,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your transaction has been sent successfully!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                txHash,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
