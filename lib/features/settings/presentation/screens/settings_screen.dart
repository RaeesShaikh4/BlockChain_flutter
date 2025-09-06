import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/wallet_provider.dart';
import '../widgets/settings_tile.dart';
import '../widgets/network_selector_dialog.dart';
import '../widgets/export_wallet_dialog.dart';
import '../widgets/authentication_settings_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);
    final networkState = ref.watch(networkProvider);
    final appSettings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Wallet Section
          _buildSection(
            context,
            'Wallet',
            [
              SettingsTile(
                icon: Icons.account_balance_wallet,
                title: 'Wallet Address',
                subtitle: walletState.address ?? 'Not available',
                onTap: () {
                  _showAddressDialog(context, walletState.address ?? '');
                },
              ),
              SettingsTile(
                icon: Icons.download,
                title: 'Export Wallet',
                subtitle: 'Export private key or mnemonic',
                onTap: () {
                  _showExportDialog(context, ref);
                },
              ),
              SettingsTile(
                icon: Icons.delete_forever,
                title: 'Delete Wallet',
                subtitle: 'Permanently delete this wallet',
                onTap: () {
                  _showDeleteWalletDialog(context, ref);
                },
                isDestructive: true,
              ),
            ],
          ),

          // Network Section
          _buildSection(
            context,
            'Network',
            [
              SettingsTile(
                icon: Icons.network_check,
                title: 'Current Network',
                subtitle: _getNetworkName(networkState.currentChainId),
                onTap: () {
                  _showNetworkSelector(context, ref);
                },
              ),
            ],
          ),

          // App Settings Section
          _buildSection(
            context,
            'App Settings',
            [
              SettingsTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: appSettings.isDarkMode ? 'Enabled' : 'Disabled',
                trailing: Switch(
                  value: appSettings.isDarkMode,
                  onChanged: (value) {
                    ref.read(appSettingsProvider.notifier).setDarkMode(value);
                  },
                ),
              ),
              SettingsTile(
                icon: Icons.security,
                title: 'Authentication Methods',
                subtitle: 'Configure how to secure your wallet',
                onTap: () {
                  _showAuthenticationSettings(context);
                },
              ),
            ],
          ),

          // Security Section
          _buildSection(
            context,
            'Security',
            [
              SettingsTile(
                icon: Icons.security,
                title: 'Security Tips',
                subtitle: 'Learn how to keep your wallet secure',
                onTap: () {
                  _showSecurityTips(context);
                },
              ),
              SettingsTile(
                icon: Icons.info,
                title: 'About',
                subtitle: 'App version and information',
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showAddressDialog(BuildContext context, String address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wallet Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                address,
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
              // TODO: Implement copy to clipboard
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Address copied to clipboard')),
              );
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const ExportWalletDialog(),
    );
  }

  void _showDeleteWalletDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Wallet'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'This action cannot be undone. All wallet data will be permanently deleted.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Make sure you have backed up your private key before proceeding.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(walletProvider.notifier).deleteWallet();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Wallet deleted successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showNetworkSelector(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const NetworkSelectorDialog(),
    );
  }

  void _showAuthenticationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AuthenticationSettingsDialog(),
    );
  }

  void _showSecurityTips(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security Tips'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SecurityTip(
                icon: Icons.lock,
                title: 'Never share your private key',
                description: 'Your private key gives full access to your wallet. Never share it with anyone.',
              ),
              _SecurityTip(
                icon: Icons.backup,
                title: 'Backup your wallet',
                description: 'Always backup your private key or mnemonic phrase in a secure location.',
              ),
              _SecurityTip(
                icon: Icons.verified_user,
                title: 'Verify addresses',
                description: 'Always double-check recipient addresses before sending transactions.',
              ),
              _SecurityTip(
                icon: Icons.security,
                title: 'Use secure networks',
                description: 'Avoid using public Wi-Fi when accessing your wallet.',
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Blockchain Flutter App',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.account_balance_wallet,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 32,
        ),
      ),
      children: [
        const Text('A secure and user-friendly blockchain wallet built with Flutter.'),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• Secure wallet management'),
        const Text('• Multi-network support'),
        const Text('• Transaction history'),
        const Text('• Biometric authentication'),
      ],
    );
  }

  String _getNetworkName(int chainId) {
    switch (chainId) {
      case 1:
        return 'Ethereum Mainnet';
      case 4:
        return 'Rinkeby Testnet';
      case 5:
        return 'Goerli Testnet';
      case 11155111:
        return 'Sepolia Testnet';
      default:
        return 'Unknown Network';
    }
  }
}

class _SecurityTip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _SecurityTip({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
