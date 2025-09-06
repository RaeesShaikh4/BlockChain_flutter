import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/wallet_provider.dart';
import '../widgets/wallet_header.dart';
import '../widgets/balance_card.dart';
import '../widgets/action_buttons.dart';
import '../widgets/transaction_list.dart';
import '../widgets/send_transaction_dialog.dart';
import '../../../../features/settings/presentation/screens/settings_screen.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load transaction history when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletProvider.notifier).loadTransactionHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    final networkState = ref.watch(networkProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          // Network indicator
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _getNetworkName(networkState.currentChainId),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          // Settings button
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(walletState),
          _buildTransactionsTab(walletState),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          
          // Load transaction history when switching to transactions tab
          if (index == 1) {
            ref.read(walletProvider.notifier).loadTransactionHistory();
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Transactions',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                _showSendDialog();
              },
              icon: const Icon(Icons.send),
              label: const Text('Send'),
            )
          : null,
    );
  }

  Widget _buildHomeTab(walletState) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(walletProvider.notifier).refreshBalance();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet Header
            WalletHeader(
              address: walletState.address ?? '',
              onCopyAddress: () {
                _copyToClipboard(walletState.address ?? '');
              },
            ),
            
            const SizedBox(height: 24),
            
            // Balance Card
            BalanceCard(
              balance: walletState.balance,
              isLoading: walletState.isLoading,
              onRefresh: () {
                ref.read(walletProvider.notifier).refreshBalance();
              },
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            ActionButtons(
              onSend: () => _showSendDialog(),
              onReceive: () => _showReceiveDialog(),
              onSwap: () => _showSwapDialog(),
              onStake: () => _showStakeDialog(),
            ),
            
            const SizedBox(height: 24),
            
            // Recent Transactions
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Transaction List (limited to 5 items)
            SizedBox(
              height: 300, // Fixed height for the preview list
              child: TransactionList(
                transactions: walletState.transactions.take(5).toList(),
                isLoading: walletState.isLoading,
                onTap: (transaction) {
                  // Navigate to transaction details
                },
              ),
            ),
            
            if (walletState.transactions.length > 5) ...[
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  child: const Text('View All Transactions'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsTab(walletState) {
    return Column(
      children: [
        // Transaction filters
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Filter by type
                  },
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Sort transactions
                  },
                  icon: const Icon(Icons.sort),
                  label: const Text('Sort'),
                ),
              ),
            ],
          ),
        ),
        
        // Transaction List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(walletProvider.notifier).loadTransactionHistory();
            },
            child: TransactionList(
              transactions: walletState.transactions,
              isLoading: walletState.isLoading,
              onTap: (transaction) {
                // Navigate to transaction details
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showSendDialog() {
    showDialog(
      context: context,
      builder: (context) => const SendTransactionDialog(),
    );
  }

  void _showReceiveDialog() {
    final walletState = ref.read(walletProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Receive'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your wallet address:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: SelectableText(
                walletState.address ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Share this address to receive funds',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              _copyToClipboard(walletState.address ?? '');
              Navigator.of(context).pop();
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  void _showSwapDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Swap feature coming soon!'),
      ),
    );
  }

  void _showStakeDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Staking feature coming soon!'),
      ),
    );
  }

  void _copyToClipboard(String text) {
    // TODO: Implement clipboard functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: ${text.substring(0, 10)}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getNetworkName(int chainId) {
    switch (chainId) {
      case 1:
        return 'Mainnet';
      case 4:
        return 'Rinkeby';
      case 5:
        return 'Goerli';
      case 11155111:
        return 'Sepolia';
      default:
        return 'Unknown';
    }
  }
}
