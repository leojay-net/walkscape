# WalkScape Contract Deployment Guide

This guide will help you deploy the WalkScape contract to CrossFi testnet.

## Prerequisites

1. **Install Foundry**
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Get CrossFi Testnet Tokens**
   - Visit CrossFi testnet faucet
   - Fund your deployment wallet with testnet tokens

3. **Prepare Your Environment**
   ```bash
   cp .env.example .env
   # Edit .env with your private key
   ```

## Quick Deployment

1. **Setup Dependencies**
   ```bash
   ./setup.sh
   ```

2. **Set Your Private Key**
   ```bash
   export PRIVATE_KEY=0x...
   ```

3. **Deploy to CrossFi Testnet**
   ```bash
   make crossfi-testnet
   ```

## Step-by-Step Deployment

### 1. Install Dependencies
```bash
./setup.sh
```

### 2. Build and Test
```bash
make build
make test
```

### 3. Configure Environment
```bash
export PRIVATE_KEY=0x...
# Optional: export ADMIN_ADDRESS=0x...
```

### 4. Deploy Contract
```bash
# Basic deployment
make deploy NETWORK=crossfi-testnet

# With verification
./deploy.sh crossfi-testnet --verify

# With test data for development
make test-deploy
```

## Post-Deployment

After successful deployment, you'll receive:

1. **Contract Address** - Use this in your frontend
2. **Deployment Info** - Saved to `deployment_info.json`
3. **Explorer Link** - View on CrossFi testnet explorer

### Verify Deployment
```bash
export CONTRACT_ADDRESS=0x...
make contract-info
```

### Add Test Data (Development)
```bash
export CONTRACT_ADDRESS=0x...
forge script script/Deploy.s.sol:RegisterTestPlayers --rpc-url https://rpc.testnet.ms --private-key $PRIVATE_KEY --broadcast
```

## Frontend Integration

Update your frontend environment variables:
```bash
NEXT_PUBLIC_CONTRACT_ADDRESS=0x...
NEXT_PUBLIC_RPC_URL=https://rpc.testnet.ms
NEXT_PUBLIC_CHAIN_ID=4157
```

## Troubleshooting

### Build Errors
```bash
# Clean and rebuild
make clean
make build
```

### Dependency Issues
```bash
# Re-run setup
./setup.sh
```

### Network Issues
```bash
# Check network connectivity
curl -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' https://rpc.testnet.ms
```

### Gas Issues
- Ensure your wallet has sufficient CrossFi testnet tokens
- Check current gas prices on the network

## Advanced Usage

### Custom Admin Address
```bash
export ADMIN_ADDRESS=0x...
make deploy
```

### Deployment with Setup Script
```bash
./deploy.sh crossfi-testnet --verify --setup --test-data
```

### Local Development
```bash
# Start local node
make local-node

# Deploy locally
make local-deploy
```

## Security Notes

- Never commit your private key to version control
- Use a dedicated deployment wallet
- Verify contract source code after deployment
- Test thoroughly on testnet before mainnet

## Support

- Check the main README.md for detailed documentation
- Review test files for usage examples
- Open an issue for bugs or questions
