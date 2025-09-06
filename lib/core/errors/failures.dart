abstract class Failure {
  final String message;
  
  const Failure({required this.message});
  
  @override
  String toString() => message;
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

// Blockchain specific failures
class BlockchainFailure extends Failure {
  const BlockchainFailure({required super.message});
}

class TransactionFailure extends Failure {
  final String? transactionHash;
  
  const TransactionFailure({
    required super.message,
    this.transactionHash,
  });
}

class WalletFailure extends Failure {
  const WalletFailure({required super.message});
}

class InsufficientFundsFailure extends Failure {
  final BigInt required;
  final BigInt available;
  
  const InsufficientFundsFailure({
    required super.message,
    required this.required,
    required this.available,
  });
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure({required super.message});
}

class SecurityFailure extends Failure {
  const SecurityFailure({required super.message});
}

class ValidationFailure extends Failure {
  final String? field;
  
  const ValidationFailure({
    required super.message,
    this.field,
  });
}
