import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';
import '../../core/constants/app_constants.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  final Logger _logger = Logger();
  
  // Private key storage
  Future<void> storePrivateKey(String privateKey) async {
    try {
      _logger.d('Storing private key securely');
      await _storage.write(key: AppConstants.privateKeyKey, value: privateKey);
      _logger.i('Private key stored successfully');
    } catch (e) {
      _logger.e('Failed to store private key: $e');
      rethrow;
    }
  }
  
  Future<String?> getPrivateKey() async {
    try {
      _logger.d('Retrieving private key');
      final privateKey = await _storage.read(key: AppConstants.privateKeyKey);
      if (privateKey != null) {
        _logger.i('Private key retrieved successfully');
      } else {
        _logger.w('No private key found');
      }
      return privateKey;
    } catch (e) {
      _logger.e('Failed to retrieve private key: $e');
      return null;
    }
  }
  
  Future<void> deletePrivateKey() async {
    try {
      _logger.d('Deleting private key');
      await _storage.delete(key: AppConstants.privateKeyKey);
      _logger.i('Private key deleted successfully');
    } catch (e) {
      _logger.e('Failed to delete private key: $e');
      rethrow;
    }
  }
  
  // Wallet address storage
  Future<void> storeWalletAddress(String address) async {
    try {
      _logger.d('Storing wallet address');
      await _storage.write(key: AppConstants.walletAddressKey, value: address);
      _logger.i('Wallet address stored successfully');
    } catch (e) {
      _logger.e('Failed to store wallet address: $e');
      rethrow;
    }
  }
  
  Future<String?> getWalletAddress() async {
    try {
      _logger.d('Retrieving wallet address');
      final address = await _storage.read(key: AppConstants.walletAddressKey);
      if (address != null) {
        _logger.i('Wallet address retrieved successfully');
      } else {
        _logger.w('No wallet address found');
      }
      return address;
    } catch (e) {
      _logger.e('Failed to retrieve wallet address: $e');
      return null;
    }
  }
  
  Future<void> deleteWalletAddress() async {
    try {
      _logger.d('Deleting wallet address');
      await _storage.delete(key: AppConstants.walletAddressKey);
      _logger.i('Wallet address deleted successfully');
    } catch (e) {
      _logger.e('Failed to delete wallet address: $e');
      rethrow;
    }
  }
  
  // Mnemonic storage
  Future<void> storeMnemonic(String mnemonic) async {
    try {
      _logger.d('Storing mnemonic securely');
      await _storage.write(key: AppConstants.mnemonicKey, value: mnemonic);
      _logger.i('Mnemonic stored successfully');
    } catch (e) {
      _logger.e('Failed to store mnemonic: $e');
      rethrow;
    }
  }
  
  Future<String?> getMnemonic() async {
    try {
      _logger.d('Retrieving mnemonic');
      final mnemonic = await _storage.read(key: AppConstants.mnemonicKey);
      if (mnemonic != null) {
        _logger.i('Mnemonic retrieved successfully');
      } else {
        _logger.w('No mnemonic found');
      }
      return mnemonic;
    } catch (e) {
      _logger.e('Failed to retrieve mnemonic: $e');
      return null;
    }
  }
  
  Future<void> deleteMnemonic() async {
    try {
      _logger.d('Deleting mnemonic');
      await _storage.delete(key: AppConstants.mnemonicKey);
      _logger.i('Mnemonic deleted successfully');
    } catch (e) {
      _logger.e('Failed to delete mnemonic: $e');
      rethrow;
    }
  }
  
  // Biometric settings storage
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      _logger.d('Setting biometric enabled: $enabled');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.biometricEnabledKey, enabled);
      _logger.i('Biometric setting updated successfully');
    } catch (e) {
      _logger.e('Failed to set biometric enabled: $e');
      rethrow;
    }
  }
  
  Future<bool> isBiometricEnabled() async {
    try {
      _logger.d('Checking biometric enabled status');
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(AppConstants.biometricEnabledKey) ?? false;
      _logger.d('Biometric enabled: $enabled');
      return enabled;
    } catch (e) {
      _logger.e('Failed to get biometric enabled status: $e');
      return false;
    }
  }
  
  // Dark mode settings storage
  Future<void> setDarkMode(bool enabled) async {
    try {
      _logger.d('Setting dark mode: $enabled');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.darkModeKey, enabled);
      _logger.i('Dark mode setting updated successfully');
    } catch (e) {
      _logger.e('Failed to set dark mode: $e');
      rethrow;
    }
  }
  
  Future<bool> isDarkMode() async {
    try {
      _logger.d('Checking dark mode status');
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(AppConstants.darkModeKey) ?? false;
      _logger.d('Dark mode enabled: $enabled');
      return enabled;
    } catch (e) {
      _logger.e('Failed to get dark mode status: $e');
      return false;
    }
  }
  
  // Generic secure storage methods
  Future<void> storeSecureData(String key, String value) async {
    try {
      _logger.d('Storing secure data for key: $key');
      await _storage.write(key: key, value: value);
      _logger.i('Secure data stored successfully');
    } catch (e) {
      _logger.e('Failed to store secure data: $e');
      rethrow;
    }
  }
  
  Future<String?> getSecureData(String key) async {
    try {
      _logger.d('Retrieving secure data for key: $key');
      final data = await _storage.read(key: key);
      if (data != null) {
        _logger.i('Secure data retrieved successfully');
      } else {
        _logger.w('No secure data found for key: $key');
      }
      return data;
    } catch (e) {
      _logger.e('Failed to retrieve secure data: $e');
      return null;
    }
  }
  
  Future<void> deleteSecureData(String key) async {
    try {
      _logger.d('Deleting secure data for key: $key');
      await _storage.delete(key: key);
      _logger.i('Secure data deleted successfully');
    } catch (e) {
      _logger.e('Failed to delete secure data: $e');
      rethrow;
    }
  }
  
  // Clear all secure data
  Future<void> clearAllSecureData() async {
    try {
      _logger.d('Clearing all secure data');
      await _storage.deleteAll();
      _logger.i('All secure data cleared successfully');
    } catch (e) {
      _logger.e('Failed to clear all secure data: $e');
      rethrow;
    }
  }
  
  // Check if wallet exists
  Future<bool> hasWallet() async {
    try {
      final privateKey = await getPrivateKey();
      final address = await getWalletAddress();
      return privateKey != null && address != null;
    } catch (e) {
      _logger.e('Failed to check wallet existence: $e');
      return false;
    }
  }
  
  // Generate encryption key
  String generateEncryptionKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }
  
  // Hash data for verification
  String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Verify data integrity
  bool verifyData(String data, String hash) {
    return hashData(data) == hash;
  }
  
  // Store encrypted data
  Future<void> storeEncryptedData(String key, String data, String encryptionKey) async {
    try {
      _logger.d('Storing encrypted data for key: $key');
      
      // Simple XOR encryption (in production, use proper encryption)
      final encryptedData = _encrypt(data, encryptionKey);
      final hash = hashData(data);
      
      await _storage.write(key: key, value: encryptedData);
      await _storage.write(key: '${key}_hash', value: hash);
      
      _logger.i('Encrypted data stored successfully');
    } catch (e) {
      _logger.e('Failed to store encrypted data: $e');
      rethrow;
    }
  }
  
  // Retrieve and decrypt data
  Future<String?> getEncryptedData(String key, String encryptionKey) async {
    try {
      _logger.d('Retrieving encrypted data for key: $key');
      
      final encryptedData = await _storage.read(key: key);
      final hash = await _storage.read(key: '${key}_hash');
      
      if (encryptedData == null || hash == null) {
        _logger.w('No encrypted data found for key: $key');
        return null;
      }
      
      final decryptedData = _decrypt(encryptedData, encryptionKey);
      
      if (!verifyData(decryptedData, hash)) {
        _logger.e('Data integrity check failed for key: $key');
        return null;
      }
      
      _logger.i('Encrypted data retrieved and verified successfully');
      return decryptedData;
    } catch (e) {
      _logger.e('Failed to retrieve encrypted data: $e');
      return null;
    }
  }
  
  // Simple XOR encryption (for demonstration - use proper encryption in production)
  String _encrypt(String data, String key) {
    final dataBytes = utf8.encode(data);
    final keyBytes = utf8.encode(key);
    final encrypted = <int>[];
    
    for (int i = 0; i < dataBytes.length; i++) {
      encrypted.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    
    return base64.encode(encrypted);
  }
  
  // Simple XOR decryption (for demonstration - use proper decryption in production)
  String _decrypt(String encryptedData, String key) {
    final encryptedBytes = base64.decode(encryptedData);
    final keyBytes = utf8.encode(key);
    final decrypted = <int>[];
    
    for (int i = 0; i < encryptedBytes.length; i++) {
      decrypted.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    
    return utf8.decode(decrypted);
  }
}
