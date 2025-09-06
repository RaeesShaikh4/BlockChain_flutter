# API Key Setup Guide

## How to Use Your MetaMask API Key

### 1. Create a `.env` file in the project root

Create a file named `.env` in the root directory of your project with the following content:

```env
# MetaMask/Infura API Configuration
INFURA_API_KEY=your_actual_infura_api_key_here

# Alternative: Alchemy API Key
# ALCHEMY_API_KEY=your_actual_alchemy_api_key_here
```

### 2. Get Your API Key

#### Option A: Infura (Recommended)
1. Go to [infura.io](https://infura.io)
2. Sign up for a free account
3. Create a new project
4. Copy your Project ID (this is your API key)
5. Replace `your_actual_infura_api_key_here` with your Project ID

#### Option B: Alchemy
1. Go to [alchemy.com](https://alchemy.com)
2. Sign up for a free account
3. Create a new app
4. Copy your API key
5. Replace `your_actual_alchemy_api_key_here` with your API key

### 3. Supported Networks

The app will automatically use your API key for:
- **Ethereum Mainnet** - Real ETH transactions
- **Sepolia Testnet** - Test network (recommended for development)
- **Goerli Testnet** - Alternative test network
- **Rinkeby Testnet** - Legacy test network

### 4. Fallback Behavior

If no API key is provided, the app will use public endpoints (slower but functional):
- Mainnet: `https://eth-mainnet.public.blastapi.io`
- Sepolia: `https://eth-sepolia.public.blastapi.io`

### 5. Security Notes

- **Never commit your `.env` file to version control**
- The `.env` file is already in `.gitignore`
- Keep your API key private and secure
- Consider using different keys for development and production

### 6. Testing Your Setup

After setting up your API key:
1. Run `flutter clean`
2. Run `flutter pub get`
3. Run `flutter run`
4. Check the console output for "API key configured successfully"

### 7. Benefits of Using an API Key

- **Faster response times** - Dedicated endpoints
- **Higher rate limits** - More requests per minute
- **Better reliability** - Professional infrastructure
- **Real-time data** - Up-to-date blockchain information
- **Transaction broadcasting** - Send real transactions

### 8. Free Tier Limits

Both Infura and Alchemy offer generous free tiers:
- **Infura**: 100,000 requests/day
- **Alchemy**: 300M compute units/month

This is more than enough for development and testing!
