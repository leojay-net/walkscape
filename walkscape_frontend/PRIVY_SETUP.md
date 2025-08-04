# Privy Setup Instructions

## 1. Get Your Privy App ID

1. Go to [Privy Dashboard](https://dashboard.privy.io)
2. Create a new app or use an existing one
3. Copy your App ID from the dashboard
4. Update your `.env.local` file with your Privy App ID

## 2. Configure Your Environment

Update your `.env.local` file:
```bash
# Replace with your actual Privy App ID
NEXT_PUBLIC_PRIVY_APP_ID=your-actual-privy-app-id-here
```

## 3. Network Configuration

The app is already configured to work with CrossFi Testnet:
- Chain ID: 4157
- RPC URL: https://rpc.testnet.ms/
- Explorer: https://explorer.testnet.ms/

## 4. Supported Login Methods

Privy is configured with the following login methods:
- Wallet (MetaMask, WalletConnect, etc.)
- Email
- SMS
- Google
- Twitter
- Discord
- GitHub

## 5. Features

- Embedded wallets for users without existing wallets
- Dark theme matching your app design
- Automatic wallet management
- Better user experience compared to AppKit
- Built-in user management

## 6. Test the Migration

1. Set your Privy App ID in `.env.local`
2. Run `npm run dev`
3. Test wallet connection
4. Verify CrossFi network support
5. Test user registration and game features

Your app will now use Privy instead of AppKit for wallet connections!
