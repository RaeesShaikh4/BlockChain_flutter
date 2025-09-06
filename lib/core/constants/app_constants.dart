class AppConstants {
  // App Information
  static const String appName = 'Blockchain Flutter App';
  static const String appVersion = '1.0.0';
  
  // Network Constants
  static const String mainnetRpcUrl = 'https://mainnet.infura.io/v3/';
  static const String rinkebyRpcUrl = 'https://rinkeby.infura.io/v3/';
  static const String goerliRpcUrl = 'https://goerli.infura.io/v3/';
  static const String sepoliaRpcUrl = 'https://sepolia.infura.io/v3/';
  
  // Gas Constants
  static const int defaultGasLimit = 21000;
  static const int contractGasLimit = 100000;
  static const int maxGasPrice = 1000000000; // 1 Gwei
  
  // Storage Keys
  static const String privateKeyKey = 'private_key';
  static const String walletAddressKey = 'wallet_address';
  static const String mnemonicKey = 'mnemonic';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String darkModeKey = 'dark_mode';
  
  // API Configuration
  static const int apiTimeout = 30000; // 30 seconds
  static const int maxRetries = 3;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int mnemonicWordCount = 12;
  
  // Error Messages
  static const String networkError = 'Network connection failed';
  static const String invalidCredentials = 'Invalid credentials';
  static const String insufficientFunds = 'Insufficient funds';
  static const String transactionFailed = 'Transaction failed';
  static const String unknownError = 'An unknown error occurred';
}
