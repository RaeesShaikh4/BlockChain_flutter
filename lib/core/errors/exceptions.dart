class ServerException implements Exception {
  final String message;
  
  const ServerException({required this.message});
  
  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  final String message;
  
  const NetworkException({required this.message});
  
  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  
  const CacheException({required this.message});
  
  @override
  String toString() => 'CacheException: $message';
}

class BlockchainException implements Exception {
  final String message;
  
  const BlockchainException({required this.message});
  
  @override
  String toString() => 'BlockchainException: $message';
}

class TransactionException implements Exception {
  final String message;
  final String? transactionHash;
  
  const TransactionException({
    required this.message,
    this.transactionHash,
  });
  
  @override
  String toString() => 'TransactionException: $message${transactionHash != null ? ' (Hash: $transactionHash)' : ''}';
}

class WalletException implements Exception {
  final String message;
  
  const WalletException({required this.message});
  
  @override
  String toString() => 'WalletException: $message';
}

class InsufficientFundsException implements Exception {
  final String message;
  final BigInt required;
  final BigInt available;
  
  const InsufficientFundsException({
    required this.message,
    required this.required,
    required this.available,
  });
  
  @override
  String toString() => 'InsufficientFundsException: $message (Required: $required, Available: $available)';
}

class InvalidCredentialsException implements Exception {
  final String message;
  
  const InvalidCredentialsException({required this.message});
  
  @override
  String toString() => 'InvalidCredentialsException: $message';
}

class SecurityException implements Exception {
  final String message;
  
  const SecurityException({required this.message});
  
  @override
  String toString() => 'SecurityException: $message';
}

class ValidationException implements Exception {
  final String message;
  final String? field;
  
  const ValidationException({
    required this.message,
    this.field,
  });
  
  @override
  String toString() => 'ValidationException: $message${field != null ? ' (Field: $field)' : ''}';
}
