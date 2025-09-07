import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/wallet_provider.dart';
import '../../../../shared/widgets/simple_logo.dart';
import '../../../../shared/widgets/logo_pull_intro.dart';
import '../../../../shared/widgets/animations.dart';
import '../widgets/create_wallet_dialog.dart';
import '../widgets/import_wallet_dialog.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo replaced with pull intro animation
                const LogoPullIntro(
                  height: 130,
                  logoSize: 120,
                  showText: true,
                ),

                const SizedBox(height: 24),

                // App Description with entrance
                FadeSlide(
                  duration: const Duration(milliseconds: 300),
                  beginOffsetY: 0.12,
                  child: Text(
                    'Secure, fast, and easy-to-use blockchain wallet for managing your digital assets.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 48),

                // Create Wallet Button
                FadeSlide(
                  duration: const Duration(milliseconds: 320),
                  child: TapScale(
                    onTap: null,
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          alignment: Alignment.center, // centers the row inside
                        ),
                        onPressed: walletState.isLoading
                            ? null
                            : () {
                                _showCreateWalletDialog(context, ref);
                              },
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Create New Wallet',),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Import Wallet Button
                FadeSlide(
                  duration: const Duration(milliseconds: 340),
                  child: TapScale(
                    onTap: null,
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: walletState.isLoading
                            ? null
                            : () {
                                _showImportWalletDialog(context, ref);
                              },
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Import Existing Wallet'),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Features List
                FadeSlide(
                  duration: const Duration(milliseconds: 380),
                  child: _buildFeaturesList(context),
                ),

                const SizedBox(height: 32),

                // Error Display
                if (walletState.error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .error
                            .withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            walletState.error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            ref.read(walletProvider.notifier).clearError();
                          },
                          icon: const Icon(Icons.close),
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      {
        'icon': Icons.security,
        'title': 'Secure',
        'description': 'Your private keys are encrypted and stored securely',
      },
      {
        'icon': Icons.speed,
        'title': 'Fast',
        'description': 'Quick transactions with optimized gas fees',
      },
      {
        'icon': Icons.phone_android,
        'title': 'Mobile',
        'description': 'Access your wallet anywhere, anytime',
      },
    ];

    return Column(
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature['title'] as String,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            feature['description'] as String,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7),
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  void _showCreateWalletDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const CreateWalletDialog(),
    );
  }

  void _showImportWalletDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const ImportWalletDialog(),
    );
  }
}
