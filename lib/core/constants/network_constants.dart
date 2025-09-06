
class NetworkConstants {
  // Network IDs
  static const int mainnetId = 1;
  static const int rinkebyId = 4;
  static const int goerliId = 5;
  static const int sepoliaId = 11155111;
  
  // Network Names
  static const String mainnetName = 'Ethereum Mainnet';
  static const String rinkebyName = 'Rinkeby Testnet';
  static const String goerliName = 'Goerli Testnet';
  static const String sepoliaName = 'Sepolia Testnet';
  
  // Chain IDs for WalletConnect
  static const String mainnetChainId = '0x1';
  static const String rinkebyChainId = '0x4';
  static const String goerliChainId = '0x5';
  static const String sepoliaChainId = '0xaa36a7';
  
  // Network URLs - These will be configured with API keys at runtime
  static String get mainnetRpcUrl => 'https://mainnet.infura.io/v3/${_getApiKey()}';
  static String get rinkebyRpcUrl => 'https://rinkeby.infura.io/v3/${_getApiKey()}';
  static String get goerliRpcUrl => 'https://goerli.infura.io/v3/${_getApiKey()}';
  static String get sepoliaRpcUrl => 'https://sepolia.infura.io/v3/${_getApiKey()}';
  
  // Fallback URLs (public endpoints - slower but no API key required)
  static const String mainnetRpcUrlFallback = 'https://eth-mainnet.public.blastapi.io';
  static const String sepoliaRpcUrlFallback = 'https://eth-sepolia.public.blastapi.io';
  
  // API Key configuration
  static String? _apiKey;
  static void setApiKey(String key) => _apiKey = key;
  static String _getApiKey() => _apiKey ?? 'demo'; // Use 'demo' as fallback
  
  // Block Explorer URLs
  static const String etherscanMainnet = 'https://etherscan.io';
  static const String etherscanRinkeby = 'https://rinkeby.etherscan.io';
  static const String etherscanGoerli = 'https://goerli.etherscan.io';
  static const String etherscanSepolia = 'https://sepolia.etherscan.io';
  
  // Native Token Information
  static const String nativeTokenSymbol = 'ETH';
  static const String nativeTokenName = 'Ethereum';
  static const int nativeTokenDecimals = 18;
  
  // Gas Price Settings (in Gwei)
  static const int slowGasPrice = 1;
  static const int standardGasPrice = 5;
  static const int fastGasPrice = 10;
  static const int instantGasPrice = 20;
  
  // Contract Addresses (Example - replace with actual addresses)
  static const String votingContractAddress = '0x0000000000000000000000000000000000000000';
  static const String tokenContractAddress = '0x0000000000000000000000000000000000000000';
  
  // Network Configuration
  static Map<int, NetworkConfig> get networkConfigs => {
    mainnetId: NetworkConfig(
      id: mainnetId,
      name: mainnetName,
      rpcUrl: mainnetRpcUrl,
      chainId: mainnetChainId,
      blockExplorer: etherscanMainnet,
      isTestnet: false,
    ),
    rinkebyId: NetworkConfig(
      id: rinkebyId,
      name: rinkebyName,
      rpcUrl: rinkebyRpcUrl,
      chainId: rinkebyChainId,
      blockExplorer: etherscanRinkeby,
      isTestnet: true,
    ),
    goerliId: NetworkConfig(
      id: goerliId,
      name: goerliName,
      rpcUrl: goerliRpcUrl,
      chainId: goerliChainId,
      blockExplorer: etherscanGoerli,
      isTestnet: true,
    ),
    sepoliaId: NetworkConfig(
      id: sepoliaId,
      name: sepoliaName,
      rpcUrl: sepoliaRpcUrl,
      chainId: sepoliaChainId,
      blockExplorer: etherscanSepolia,
      isTestnet: true,
    ),
  };
}

class NetworkConfig {
  final int id;
  final String name;
  final String rpcUrl;
  final String chainId;
  final String blockExplorer;
  final bool isTestnet;
  
  const NetworkConfig({
    required this.id,
    required this.name,
    required this.rpcUrl,
    required this.chainId,
    required this.blockExplorer,
    required this.isTestnet,
  });
}
