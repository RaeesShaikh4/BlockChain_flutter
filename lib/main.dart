import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/network_constants.dart';
import 'shared/providers/wallet_provider.dart';
import 'shared/widgets/authentication_flow.dart';
import 'features/wallet/presentation/screens/wallet_screen.dart';
import 'features/auth/presentation/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    
    // Configure API key for blockchain services
    final apiKey = dotenv.env['INFURA_API_KEY'] ?? dotenv.env['ALCHEMY_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      NetworkConstants.setApiKey(apiKey);
      debugPrint('API key configured successfully');
    } else {
      debugPrint('Warning: No API key found. Using fallback endpoints.');
    }
  } catch (e) {
    // Handle case where .env file doesn't exist
    debugPrint('Warning: .env file not found. Using default values.');
  }
  
  runApp(const ProviderScope(child: BlockchainApp()));
}

class BlockchainApp extends ConsumerWidget {
  const BlockchainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider);
    
    return MaterialApp(
      title: 'Blockchain Flutter App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appSettings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AppRouter(),
    );
  }
}

class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);
    
    // Show loading screen while initializing
    if (walletState.isLoading) {
      return const LoadingScreen();
    }
    
    // Show welcome screen if wallet is not initialized
    if (!walletState.isInitialized) {
      return const WelcomeScreen();
    }
    
    // Show main app if wallet is initialized - wrap with authentication
    return AuthenticationFlow(
      reason: 'Authenticate to access your wallet',
      child: const WalletScreen(),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
