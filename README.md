# Blockchain Flutter App

A production-ready Flutter blockchain application with Web3 integration, built following clean architecture principles.

## Features

- 🔐 **Secure Wallet Management**: Create, import, and manage Ethereum wallets
- 🌐 **Multi-Network Support**: Support for Mainnet, Rinkeby, Goerli, and Sepolia networks
- 💰 **Transaction Management**: Send and receive ETH with gas optimization
- 📱 **Modern UI**: Beautiful, responsive design with dark mode support
- 🔒 **Security**: Encrypted storage, biometric authentication, and secure key management
- 📊 **Transaction History**: View and track all your transactions
- ⚙️ **Settings**: Comprehensive settings with network switching and wallet export

## Architecture

The app follows clean architecture principles with clear separation of concerns:

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants and network configurations
│   ├── errors/             # Error handling and custom exceptions
│   ├── theme/              # App theming and styling
│   └── utils/              # Utility functions
├── features/               # Feature-based modules
│   ├── auth/               # Authentication and wallet creation
│   ├── wallet/             # Wallet management and transactions
│   └── settings/           # App settings and configuration
└── shared/                 # Shared components
    ├── providers/          # State management with Riverpod
    ├── services/           # Business logic and API services
    ├── widgets/            # Reusable UI components
    └── models/             # Data models
```

## Getting Started

### Prerequisites

- Flutter SDK (3.6.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd blockchain_flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` file with your configuration:
   ```env
   # Network Configuration
   NETWORK_NAME=sepolia
   INFURA_PROJECT_ID=your_infura_project_id_here
   INFURA_RPC_URL=https://sepolia.infura.io/v3/
   
   # Security
   ENCRYPTION_KEY=your_32_character_encryption_key_here
   BIOMETRIC_ENABLED=true
   
   # App Configuration
   DEBUG_MODE=true
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Configuration

### Network Setup

The app supports multiple Ethereum networks:

- **Mainnet**: Production Ethereum network
- **Rinkeby**: Ethereum testnet (deprecated)
- **Goerli**: Ethereum testnet (deprecated)
- **Sepolia**: Ethereum testnet (recommended for development)

### Infura Setup

1. Create an account at [Infura](https://infura.io/)
2. Create a new project
3. Copy your Project ID
4. Add it to your `.env` file

### Security Configuration

- **Encryption Key**: Generate a 32-character encryption key for secure storage
- **Biometric Authentication**: Enable/disable biometric authentication
- **Private Key Storage**: Private keys are encrypted and stored securely

## Usage

### Creating a Wallet

1. Launch the app
2. Tap "Create New Wallet"
3. Read the security warning
4. Confirm wallet creation
5. Backup your private key securely

### Importing a Wallet

1. Tap "Import Existing Wallet"
2. Choose between Private Key or Mnemonic
3. Enter your credentials
4. Confirm import

### Sending Transactions

1. Tap the "Send" button
2. Enter recipient address
3. Enter amount
4. Configure gas settings (optional)
5. Confirm transaction

### Network Switching

1. Go to Settings
2. Tap "Current Network"
3. Select desired network
4. Confirm switch

## Security Best Practices

- **Never share your private key** with anyone
- **Always backup your wallet** before making changes
- **Use testnets** for development and testing
- **Verify addresses** before sending transactions
- **Keep your app updated** for security patches

## Development

### Running Tests

```bash
flutter test
```

### Code Generation

```bash
flutter packages pub run build_runner build
```

### Linting

```bash
flutter analyze
```

## Dependencies

### Core Dependencies

- **web3dart**: Ethereum blockchain interaction
- **flutter_riverpod**: State management
- **flutter_secure_storage**: Secure credential storage
- **google_fonts**: Typography
- **intl**: Internationalization

### Development Dependencies

- **flutter_lints**: Code linting
- **very_good_analysis**: Advanced linting rules
- **mockito**: Testing utilities

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:

- Create an issue on GitHub
- Check the documentation
- Review the code examples

## Roadmap

- [ ] Multi-token support
- [ ] DeFi integrations
- [ ] NFT support
- [ ] WalletConnect integration
- [ ] Hardware wallet support
- [ ] Advanced transaction features

## Disclaimer

This software is for educational and development purposes. Always use testnets for development and testing. Never use real funds on untested networks or with unverified contracts.