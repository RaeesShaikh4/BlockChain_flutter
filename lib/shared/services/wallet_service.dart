import 'package:logger/logger.dart';
import 'simple_blockchain_service.dart';
import 'secure_storage_service.dart';
import '../../core/errors/exceptions.dart';

class WalletService {
  final SimpleBlockchainService _blockchainService;
  final SecureStorageService _secureStorageService;
  final Logger _logger = Logger();
  
  String? _privateKey;
  String? _address;
  
  WalletService({
    required SimpleBlockchainService blockchainService,
    required SecureStorageService secureStorageService,
  }) : _blockchainService = blockchainService,
       _secureStorageService = secureStorageService;
  
  /// Initialize wallet from stored credentials
  Future<void> initializeWallet() async {
    try {
      _logger.d('Initializing wallet from stored credentials');
      
      final privateKey = await _secureStorageService.getPrivateKey();
      final address = await _secureStorageService.getWalletAddress();
      
      if (privateKey != null && address != null) {
        _privateKey = privateKey;
        _address = address;
        _logger.i('Wallet initialized successfully: $_address');
      } else {
        _logger.w('No stored wallet found');
      }
    } catch (e) {
      _logger.e('Failed to initialize wallet: $e');
      throw WalletException(message: 'Failed to initialize wallet: $e');
    }
  }
  
  /// Create a new wallet
  Future<WalletInfo> createWallet() async {
    try {
      _logger.d('Creating new wallet');
      
      final walletInfo = await _blockchainService.generateWallet();
      
      // Store credentials securely
      await _secureStorageService.storePrivateKey(walletInfo.privateKey);
      await _secureStorageService.storeWalletAddress(walletInfo.address);
      
      // Set current credentials
      _privateKey = walletInfo.privateKey;
      _address = walletInfo.address;
      
      _logger.i('New wallet created and stored: ${walletInfo.address}');
      
      return walletInfo;
    } catch (e) {
      _logger.e('Failed to create wallet: $e');
      throw WalletException(message: 'Failed to create wallet: $e');
    }
  }
  
  /// Import wallet from private key
  Future<void> importWallet(String privateKey) async {
    try {
      _logger.d('Importing wallet from private key');
      
      // Validate private key
      if (!_blockchainService.isValidPrivateKey(privateKey)) {
        throw InvalidCredentialsException(message: 'Invalid private key format');
      }
      
      // Create credentials
      final credentials = _blockchainService.createCredentials(privateKey);
      
      // For demo purposes, generate a mock address
      // In real implementation, derive address from private key
      final address = '0x${List.generate(20, (i) => i.toString().padLeft(2, '0')).join()}';
      
      // Store credentials securely
      await _secureStorageService.storePrivateKey(privateKey);
      await _secureStorageService.storeWalletAddress(address);
      
      // Set current credentials
      _privateKey = privateKey;
      _address = address;
      
      _logger.i('Wallet imported successfully: $address');
    } catch (e) {
      _logger.e('Failed to import wallet: $e');
      if (e is InvalidCredentialsException) {
        rethrow;
      }
      throw WalletException(message: 'Failed to import wallet: $e');
    }
  }
  
  /// Import wallet from mnemonic
  Future<void> importWalletFromMnemonic(String mnemonic) async {
    try {
      _logger.d('Importing wallet from mnemonic');
      
      // Validate mnemonic
      if (!_isValidMnemonic(mnemonic)) {
        throw InvalidCredentialsException(message: 'Invalid mnemonic format');
      }
      
      // Store mnemonic securely
      await _secureStorageService.storeMnemonic(mnemonic);
      
      // TODO: Implement mnemonic to private key conversion
      // This would require additional libraries like bip39
      throw WalletException(message: 'Mnemonic import not yet implemented');
    } catch (e) {
      _logger.e('Failed to import wallet from mnemonic: $e');
      if (e is InvalidCredentialsException) {
        rethrow;
      }
      throw WalletException(message: 'Failed to import wallet from mnemonic: $e');
    }
  }
  
  /// Get current wallet address
  String? get currentAddress => _address;
  
  /// Get current private key
  String? get currentPrivateKey => _privateKey;
  
  /// Check if wallet is initialized
  bool get isWalletInitialized => _privateKey != null && _address != null;
  
  /// Get wallet balance
  Future<double> getBalance() async {
    if (!isWalletInitialized) {
      throw WalletException(message: 'Wallet not initialized');
    }
    
    try {
      _logger.d('Getting wallet balance');
      final balance = await _blockchainService.getBalanceInEth(_address!);
      _logger.d('Wallet balance: $balance ETH');
      return balance;
    } catch (e) {
      _logger.e('Failed to get wallet balance: $e');
      throw WalletException(message: 'Failed to get wallet balance: $e');
    }
  }
  
  /// Send ETH to another address
  Future<String> sendEth({
    required String toAddress,
    required double amount,
    int? gasLimit,
    double? gasPrice,
  }) async {
    if (!isWalletInitialized) {
      throw WalletException(message: 'Wallet not initialized');
    }
    
    try {
      _logger.d('Sending $amount ETH to $toAddress');
      
      // Validate recipient address
      if (!_blockchainService.isValidAddress(toAddress)) {
        throw ValidationException(message: 'Invalid recipient address');
      }
      
      // Validate amount
      if (amount <= 0) {
        throw ValidationException(message: 'Amount must be greater than 0');
      }
      
      // Check balance
      final balance = await getBalance();
      if (balance < amount) {
        throw InsufficientFundsException(
          message: 'Insufficient funds',
          required: BigInt.from(amount * 1e18),
          available: BigInt.from(balance * 1e18),
        );
      }
      
      // Send transaction
      final txHash = await _blockchainService.sendTransaction(
        fromAddress: _address!,
        toAddress: toAddress,
        amount: amount,
        gasLimit: gasLimit,
        gasPrice: gasPrice,
      );
      
      _logger.i('ETH sent successfully: $txHash');
      return txHash;
    } catch (e) {
      _logger.e('Failed to send ETH: $e');
      if (e is ValidationException || e is InsufficientFundsException) {
        rethrow;
      }
      throw WalletException(message: 'Failed to send ETH: $e');
    }
  }
  
  /// Send contract transaction
  Future<String> sendContractTransaction({
    required String contractAddress,
    required String functionName,
    required List<dynamic> parameters,
    double? value,
    int? gasLimit,
    double? gasPrice,
  }) async {
    if (!isWalletInitialized) {
      throw WalletException(message: 'Wallet not initialized');
    }
    
    try {
      _logger.d('Sending contract transaction: $functionName');
      
      // Validate contract address
      if (!_blockchainService.isValidAddress(contractAddress)) {
        throw ValidationException(message: 'Invalid contract address');
      }
      
      // Convert value if provided
      if (value != null && value > 0) {
        // Value handling for contract transactions
      }
      
      // TODO: Implement contract function call
      // This would require contract ABI and function definition
      throw WalletException(message: 'Contract transactions not yet implemented');
    } catch (e) {
      _logger.e('Failed to send contract transaction: $e');
      if (e is ValidationException) {
        rethrow;
      }
      throw WalletException(message: 'Failed to send contract transaction: $e');
    }
  }
  
  /// Get transaction history
  Future<List<TransactionInfo>> getTransactionHistory({
    int limit = 10,
    int offset = 0,
  }) async {
    if (!isWalletInitialized) {
      throw WalletException(message: 'Wallet not initialized');
    }
    
    try {
      _logger.d('Getting transaction history');
      
      // TODO: Implement transaction history retrieval
      // This would require integration with block explorer APIs
      throw WalletException(message: 'Transaction history not yet implemented');
    } catch (e) {
      _logger.e('Failed to get transaction history: $e');
      throw WalletException(message: 'Failed to get transaction history: $e');
    }
  }
  
  /// Export private key
  Future<String> exportPrivateKey() async {
    if (!isWalletInitialized) {
      throw WalletException(message: 'Wallet not initialized');
    }
    
    try {
      _logger.d('Exporting private key');
      
      final privateKey = await _secureStorageService.getPrivateKey();
      if (privateKey == null) {
        throw WalletException(message: 'Private key not found');
      }
      
      _logger.i('Private key exported successfully');
      return privateKey;
    } catch (e) {
      _logger.e('Failed to export private key: $e');
      throw WalletException(message: 'Failed to export private key: $e');
    }
  }
  
  /// Export mnemonic
  Future<String?> exportMnemonic() async {
    try {
      _logger.d('Exporting mnemonic');
      
      final mnemonic = await _secureStorageService.getMnemonic();
      if (mnemonic == null) {
        _logger.w('No mnemonic found');
        return null;
      }
      
      _logger.i('Mnemonic exported successfully');
      return mnemonic;
    } catch (e) {
      _logger.e('Failed to export mnemonic: $e');
      throw WalletException(message: 'Failed to export mnemonic: $e');
    }
  }
  
  /// Delete wallet
  Future<void> deleteWallet() async {
    try {
      _logger.d('Deleting wallet');
      
      // Clear stored credentials
      await _secureStorageService.deletePrivateKey();
      await _secureStorageService.deleteWalletAddress();
      await _secureStorageService.deleteMnemonic();
      
      // Clear current credentials
      _privateKey = null;
      _address = null;
      
      _logger.i('Wallet deleted successfully');
    } catch (e) {
      _logger.e('Failed to delete wallet: $e');
      throw WalletException(message: 'Failed to delete wallet: $e');
    }
  }
  
  /// Validate mnemonic format
  bool _isValidMnemonic(String mnemonic) {
    // Basic validation - should be 12 or 24 words
    final words = mnemonic.trim().split(RegExp(r'\s+'));
    return words.length == 12 || words.length == 24;
  }
  
  /// Get wallet info
  WalletInfo? getWalletInfo() {
    if (!isWalletInitialized) {
      return null;
    }
    
    return WalletInfo(
      address: _address!,
      privateKey: _privateKey!,
      mnemonic: null, // Would need to retrieve from storage
    );
  }
}

class TransactionInfo {
  final String hash;
  final String from;
  final String to;
  final double value;
  final String status;
  final DateTime timestamp;
  final int blockNumber;
  
  const TransactionInfo({
    required this.hash,
    required this.from,
    required this.to,
    required this.value,
    required this.status,
    required this.timestamp,
    required this.blockNumber,
  });
}
