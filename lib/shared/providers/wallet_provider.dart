import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/simple_wallet_service.dart';
import '../services/simple_blockchain_service.dart';
import '../services/secure_storage_service.dart';

// Service providers
final blockchainServiceProvider = Provider<SimpleBlockchainService>((ref) {
  return SimpleBlockchainService();
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final walletServiceProvider = Provider<SimpleWalletService>((ref) {
  return SimpleWalletService(
    blockchainService: ref.read(blockchainServiceProvider),
    secureStorageService: ref.read(secureStorageServiceProvider),
  );
});

// Wallet state
class WalletState {
  final bool isLoading;
  final bool isInitialized;
  final String? address;
  final double balance;
  final String? error;
  final List<TransactionInfo> transactions;
  
  const WalletState({
    this.isLoading = false,
    this.isInitialized = false,
    this.address,
    this.balance = 0.0,
    this.error,
    this.transactions = const [],
  });
  
  WalletState copyWith({
    bool? isLoading,
    bool? isInitialized,
    String? address,
    double? balance,
    String? error,
    List<TransactionInfo>? transactions,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      address: address ?? this.address,
      balance: balance ?? this.balance,
      error: error,
      transactions: transactions ?? this.transactions,
    );
  }
}

// Wallet notifier
class WalletNotifier extends StateNotifier<WalletState> {
  final SimpleWalletService _walletService;
  
  WalletNotifier(this._walletService) : super(const WalletState()) {
    _initializeWallet();
  }
  
  Future<void> _initializeWallet() async {
    print('🔄 Starting wallet initialization...');
    state = state.copyWith(isLoading: true, error: null);
    
    // Ensure loading screen shows for at least 3 seconds
    final startTime = DateTime.now();
    
    try {
      await _walletService.initializeWallet();
      
      if (_walletService.isWalletInitialized) {
        final balance = await _walletService.getBalance();
        
        // Calculate remaining time to ensure minimum 3 seconds
        final elapsed = DateTime.now().difference(startTime);
        final remainingTime = const Duration(seconds: 3).inMilliseconds - elapsed.inMilliseconds;
        
        print('⏱️ Elapsed time: ${elapsed.inMilliseconds}ms, Remaining: ${remainingTime}ms');
        
        if (remainingTime > 0) {
          print('⏳ Waiting ${remainingTime}ms more...');
          await Future.delayed(Duration(milliseconds: remainingTime));
        }
        
        print('✅ Wallet initialization complete, updating state...');
        state = state.copyWith(
          isLoading: false,
          isInitialized: true,
          address: _walletService.currentAddress,
          balance: balance,
        );
      } else {
        // Calculate remaining time to ensure minimum 3 seconds
        final elapsed = DateTime.now().difference(startTime);
        final remainingTime = const Duration(seconds: 3).inMilliseconds - elapsed.inMilliseconds;
        
        if (remainingTime > 0) {
          await Future.delayed(Duration(milliseconds: remainingTime));
        }
        
        state = state.copyWith(
          isLoading: false,
          isInitialized: false,
        );
      }
    } catch (e) {
      // Calculate remaining time to ensure minimum 3 seconds
      final elapsed = DateTime.now().difference(startTime);
      final remainingTime = const Duration(seconds: 3).inMilliseconds - elapsed.inMilliseconds;
      
      if (remainingTime > 0) {
        await Future.delayed(Duration(milliseconds: remainingTime));
      }
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> createWallet() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _walletService.createWallet();
      final balance = await _walletService.getBalance();
      
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        address: _walletService.currentAddress,
        balance: balance,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> importWallet(String privateKey) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _walletService.importWallet(privateKey);
      final balance = await _walletService.getBalance();
      
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        address: _walletService.currentAddress,
        balance: balance,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> importWalletFromMnemonic(String mnemonic) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _walletService.importWalletFromMnemonic(mnemonic);
      final balance = await _walletService.getBalance();
      
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        address: _walletService.currentAddress,
        balance: balance,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> refreshBalance() async {
    if (!_walletService.isWalletInitialized) return;
    
    try {
      final balance = await _walletService.getBalance();
      state = state.copyWith(balance: balance);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  Future<String?> sendEth({
    required String toAddress,
    required double amount,
    int? gasLimit,
    double? gasPrice,
  }) async {
    if (!_walletService.isWalletInitialized) {
      state = state.copyWith(error: 'Wallet not initialized');
      return null;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final txHash = await _walletService.sendEth(
        toAddress: toAddress,
        amount: amount,
        gasLimit: gasLimit,
        gasPrice: gasPrice,
      );
      
      // Refresh balance after successful transaction
      await refreshBalance();
      
      state = state.copyWith(isLoading: false);
      return txHash;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }
  
  Future<void> loadTransactionHistory() async {
    if (!_walletService.isWalletInitialized) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final transactions = await _walletService.getTransactionHistory();
      state = state.copyWith(
        isLoading: false,
        transactions: transactions,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> deleteWallet() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _walletService.deleteWallet();
      state = const WalletState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  void clearError() {
    state = state.copyWith(error: null);
  }
  
  /// Export private key
  Future<String> exportPrivateKey() async {
    if (!_walletService.isWalletInitialized) {
      throw Exception('Wallet not initialized');
    }
    
    return await _walletService.exportPrivateKey();
  }
  
  /// Export mnemonic
  Future<String?> exportMnemonic() async {
    return await _walletService.exportMnemonic();
  }
}

// Wallet provider
final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(ref.read(walletServiceProvider));
});

// Network state
class NetworkState {
  final bool isLoading;
  final int currentChainId;
  final String? error;
  
  const NetworkState({
    this.isLoading = false,
    this.currentChainId = 11155111, // Sepolia testnet
    this.error,
  });
  
  NetworkState copyWith({
    bool? isLoading,
    int? currentChainId,
    String? error,
  }) {
    return NetworkState(
      isLoading: isLoading ?? this.isLoading,
      currentChainId: currentChainId ?? this.currentChainId,
      error: error,
    );
  }
}

// Network notifier
class NetworkNotifier extends StateNotifier<NetworkState> {
  final SimpleBlockchainService _blockchainService;
  
  NetworkNotifier(this._blockchainService) : super(const NetworkState());
  
  Future<void> switchNetwork(int chainId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _blockchainService.switchNetwork(chainId);
      state = state.copyWith(
        isLoading: false,
        currentChainId: chainId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Network provider
final networkProvider = StateNotifierProvider<NetworkNotifier, NetworkState>((ref) {
  return NetworkNotifier(ref.read(blockchainServiceProvider));
});

// App settings state
class AppSettingsState {
  final bool isDarkMode;
  final bool isBiometricEnabled;
  final bool isLoading;
  final String? error;
  
  const AppSettingsState({
    this.isDarkMode = false,
    this.isBiometricEnabled = false,
    this.isLoading = false,
    this.error,
  });
  
  AppSettingsState copyWith({
    bool? isDarkMode,
    bool? isBiometricEnabled,
    bool? isLoading,
    String? error,
  }) {
    return AppSettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// App settings notifier
class AppSettingsNotifier extends StateNotifier<AppSettingsState> {
  final SecureStorageService _secureStorageService;
  
  AppSettingsNotifier(this._secureStorageService) : super(const AppSettingsState()) {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final isDarkMode = await _secureStorageService.isDarkMode();
      final isBiometricEnabled = await _secureStorageService.isBiometricEnabled();
      
      state = state.copyWith(
        isLoading: false,
        isDarkMode: isDarkMode,
        isBiometricEnabled: isBiometricEnabled,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> setDarkMode(bool enabled) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _secureStorageService.setDarkMode(enabled);
      state = state.copyWith(
        isLoading: false,
        isDarkMode: enabled,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> setBiometricEnabled(bool enabled) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _secureStorageService.setBiometricEnabled(enabled);
      state = state.copyWith(
        isLoading: false,
        isBiometricEnabled: enabled,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// App settings provider
final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettingsState>((ref) {
  return AppSettingsNotifier(ref.read(secureStorageServiceProvider));
});
