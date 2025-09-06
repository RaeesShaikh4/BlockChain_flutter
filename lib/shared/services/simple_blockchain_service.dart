import 'dart:math';
import 'package:logger/logger.dart';
import '../../core/constants/network_constants.dart';
import '../../core/errors/exceptions.dart';

class SimpleBlockchainService {
  final Logger _logger = Logger();
  late String _rpcUrl;
  late int _chainId;
  
  SimpleBlockchainService() {
    _initializeClient();
  }
  
  void _initializeClient() {
    // Default to Sepolia testnet for development
    _chainId = NetworkConstants.sepoliaId;
    _rpcUrl = NetworkConstants.sepoliaRpcUrl;
  }
  
  /// Switch to a different network
  Future<void> switchNetwork(int chainId) async {
    try {
      final networkConfig = NetworkConstants.networkConfigs[chainId];
      if (networkConfig == null) {
        throw BlockchainException(message: 'Unsupported network: $chainId');
      }
      
      _chainId = chainId;
      _rpcUrl = networkConfig.rpcUrl;
      
      _logger.i('Switched to network: ${networkConfig.name}');
    } catch (e) {
      _logger.e('Failed to switch network: $e');
      throw BlockchainException(message: 'Failed to switch network: $e');
    }
  }
  
  /// Get current network information
  NetworkConfig get currentNetwork => NetworkConstants.networkConfigs[_chainId]!;
  
  /// Get account balance (simplified)
  Future<double> getBalanceInEth(String address) async {
    try {
      _logger.d('Getting balance for address: $address');
      
      // For demo purposes, return a random balance
      // In a real implementation, you would call the blockchain RPC
      final random = Random();
      final balance = random.nextDouble() * 10; // Random balance between 0-10 ETH
      
      _logger.d('Balance: $balance ETH');
      return balance;
    } catch (e) {
      _logger.e('Failed to get balance: $e');
      throw BlockchainException(message: 'Failed to get balance: $e');
    }
  }
  
  /// Send a transaction (simplified)
  Future<String> sendTransaction({
    required String fromAddress,
    required String toAddress,
    required double amount,
    int? gasLimit,
    double? gasPrice,
  }) async {
    try {
      _logger.d('Sending transaction from $fromAddress to $toAddress');
      
      // For demo purposes, return a mock transaction hash
      // In a real implementation, you would sign and broadcast the transaction
      final random = Random();
      final txHash = '0x${random.nextInt(0xffffffff).toRadixString(16).padLeft(8, '0')}${random.nextInt(0xffffffff).toRadixString(16).padLeft(8, '0')}${random.nextInt(0xffffffff).toRadixString(16).padLeft(8, '0')}${random.nextInt(0xffffffff).toRadixString(16).padLeft(8, '0')}';
      
      _logger.i('Transaction sent successfully: $txHash');
      return txHash;
    } catch (e) {
      _logger.e('Failed to send transaction: $e');
      throw TransactionException(message: 'Failed to send transaction: $e');
    }
  }
  
  /// Generate a new wallet (simplified)
  Future<WalletInfo> generateWallet() async {
    try {
      _logger.d('Generating new wallet');
      
      final random = Random.secure();
      final privateKey = '0x${List.generate(32, (i) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';
      final address = '0x${List.generate(20, (i) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';
      
      _logger.i('New wallet generated: $address');
      
      return WalletInfo(
        address: address,
        privateKey: privateKey,
        mnemonic: null,
      );
    } catch (e) {
      _logger.e('Failed to generate wallet: $e');
      throw WalletException(message: 'Failed to generate wallet: $e');
    }
  }
  
  /// Create credentials from private key (simplified)
  String createCredentials(String privateKey) {
    try {
      _logger.d('Creating credentials from private key');
      
      // Remove 0x prefix if present
      final cleanPrivateKey = privateKey.startsWith('0x') 
          ? privateKey.substring(2) 
          : privateKey;
      
      if (cleanPrivateKey.length != 64) {
        throw InvalidCredentialsException(message: 'Invalid private key length');
      }
      
      return cleanPrivateKey;
    } catch (e) {
      _logger.e('Failed to create credentials: $e');
      throw InvalidCredentialsException(message: 'Invalid private key format');
    }
  }
  
  /// Validate Ethereum address
  bool isValidAddress(String address) {
    try {
      if (!address.startsWith('0x') || address.length != 42) {
        return false;
      }
      
      // Check if it's valid hex
      final cleanAddress = address.substring(2);
      return RegExp(r'^[0-9a-fA-F]+$').hasMatch(cleanAddress);
    } catch (e) {
      return false;
    }
  }
  
  /// Validate private key
  bool isValidPrivateKey(String privateKey) {
    try {
      final cleanPrivateKey = privateKey.startsWith('0x') 
          ? privateKey.substring(2) 
          : privateKey;
      
      return cleanPrivateKey.length == 64 && 
             RegExp(r'^[0-9a-fA-F]+$').hasMatch(cleanPrivateKey);
    } catch (e) {
      return false;
    }
  }
}

class WalletInfo {
  final String address;
  final String privateKey;
  final String? mnemonic;
  
  const WalletInfo({
    required this.address,
    required this.privateKey,
    this.mnemonic,
  });
}
