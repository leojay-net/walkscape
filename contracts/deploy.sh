#!/bin/bash

# WalkScape Solidity Contract Deployment Script
# This script deploys the WalkScape contract to various networks

set -e

echo "🌱 WalkScape Solidity Contract Deployment"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if required tools are installed
if ! command -v forge &> /dev/null; then
    echo -e "${RED}❌ Error: forge not found. Please install Foundry.${NC}"
    echo "Visit: https://getfoundry.sh/"
    exit 1
fi

if ! command -v cast &> /dev/null; then
    echo -e "${RED}❌ Error: cast not found. Please install Foundry.${NC}"
    echo "Visit: https://getfoundry.sh/"
    exit 1
fi

# Function to display usage
usage() {
    echo "Usage: $0 [NETWORK] [OPTIONS]"
    echo ""
    echo "Networks:"
    echo "  crossfi-testnet Deploy to CrossFi testnet"
    echo "  local           Deploy to local anvil network"
    echo ""
    echo "Options:"
    echo "  --verify        Verify contract on block explorer"
    echo "  --admin <addr>  Set custom admin address"
    echo "  --setup         Run post-deployment setup"
    echo "  --test-data     Add test players and data"
    echo "  --help          Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  PRIVATE_KEY     Private key for deployment (required)"
    echo "  ADMIN_ADDRESS   Admin address (optional, defaults to deployer)"
    echo "  RPC_URL         Custom RPC URL (optional)"
    echo ""
    echo "Examples:"
    echo "  $0 crossfi-testnet --verify"
    echo "  $0 local --setup --test-data"
    echo "  $0 crossfi-testnet --admin 0x123...abc --verify"
}

# Parse command line arguments
NETWORK=""
VERIFY=false
SETUP=false
TEST_DATA=false
ADMIN_ADDRESS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        crossfi-testnet|local)
            NETWORK="$1"
            shift
            ;;
        --verify)
            VERIFY=true
            shift
            ;;
        --admin)
            ADMIN_ADDRESS="$2"
            shift 2
            ;;
        --setup)
            SETUP=true
            shift
            ;;
        --test-data)
            TEST_DATA=true
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            usage
            exit 1
            ;;
    esac
done

if [[ -z "$NETWORK" ]]; then
    echo -e "${RED}❌ Error: Network not specified${NC}"
    usage
    exit 1
fi

# Check for private key
if [[ -z "$PRIVATE_KEY" ]]; then
    echo -e "${RED}❌ Error: PRIVATE_KEY environment variable not set${NC}"
    echo "Please set your private key: export PRIVATE_KEY=0x..."
    exit 1
fi

# Set network-specific configurations
case $NETWORK in
    crossfi-testnet)
        RPC_URL=${RPC_URL:-"https://rpc.testnet.ms"}
        CHAIN_ID=4157
        EXPLORER_URL="https://scan.testnet.ms"
        EXPLORER_API_KEY=${CROSSFI_API_KEY}
        ;;
    local)
        RPC_URL=${RPC_URL:-"http://localhost:8545"}
        CHAIN_ID=31337
        EXPLORER_URL=""
        EXPLORER_API_KEY=""
        ;;
    *)
        echo -e "${RED}❌ Unsupported network: $NETWORK${NC}"
        echo "Supported networks: crossfi-testnet, local"
        exit 1
        ;;
esac

echo -e "${BLUE}📋 Deployment Configuration:${NC}"
echo "  Network: $NETWORK"
echo "  Chain ID: $CHAIN_ID"
echo "  RPC URL: $RPC_URL"
echo "  Admin: ${ADMIN_ADDRESS:-"(will use deployer address)"}"
echo "  Verify: $VERIFY"
echo "  Setup: $SETUP"
echo "  Test Data: $TEST_DATA"
echo ""

# Build the contract
echo -e "${YELLOW}🔨 Building WalkScape contract...${NC}"
forge build
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed. Please fix compilation errors.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Contract built successfully!${NC}"

# Set admin address if provided
if [[ -n "$ADMIN_ADDRESS" ]]; then
    export ADMIN_ADDRESS="$ADMIN_ADDRESS"
fi

# Deploy the contract
echo -e "${YELLOW}🚀 Deploying WalkScapeCore contract...${NC}"

DEPLOY_CMD="forge script script/Deploy.s.sol:DeployWalkScapeCore --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast"

if [[ "$VERIFY" == true && -n "$EXPLORER_API_KEY" ]]; then
    DEPLOY_CMD="$DEPLOY_CMD --verify --etherscan-api-key $EXPLORER_API_KEY"
elif [[ "$VERIFY" == true && "$NETWORK" == "crossfi-testnet" ]]; then
    echo -e "${YELLOW}⚠️  Note: Contract verification on CrossFi testnet may require manual verification${NC}"
elif [[ "$VERIFY" == true ]]; then
    echo -e "${YELLOW}⚠️  Warning: Verification requested but no API key found for $NETWORK${NC}"
fi

# Execute deployment
eval $DEPLOY_CMD

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Deployment failed.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Contract deployed successfully!${NC}"

# Extract contract address from deployment artifacts
CONTRACT_ADDRESS=$(forge script script/Deploy.s.sol:DeployWalkScapeCore --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast 2>/dev/null | grep "Contract Address:" | awk '{print $3}')

if [[ -z "$CONTRACT_ADDRESS" ]]; then
    echo -e "${YELLOW}⚠️  Could not extract contract address automatically${NC}"
    echo "Please check the deployment logs above for the contract address."
else
    export CONTRACT_ADDRESS="$CONTRACT_ADDRESS"
    echo -e "${GREEN}📋 Contract Address: $CONTRACT_ADDRESS${NC}"
fi

# Post-deployment setup
if [[ "$SETUP" == true && -n "$CONTRACT_ADDRESS" ]]; then
    echo -e "${YELLOW}⚙️  Running post-deployment setup...${NC}"
    forge script script/Deploy.s.sol:SetupWalkScapeCore --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
    echo -e "${GREEN}✅ Setup completed!${NC}"
fi

# Add test data
if [[ "$TEST_DATA" == true && -n "$CONTRACT_ADDRESS" ]]; then
    echo -e "${YELLOW}🧪 Adding test data...${NC}"
    forge script script/Deploy.s.sol:RegisterTestPlayers --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
    echo -e "${GREEN}✅ Test data added!${NC}"
fi

# Display final information
echo ""
echo -e "${GREEN}🎉 WalkScape Contract Deployment Complete!${NC}"
echo "==========================================="
echo -e "${BLUE}📋 Contract Address:${NC} $CONTRACT_ADDRESS"
echo -e "${BLUE}🌐 Network:${NC} $NETWORK (Chain ID: $CHAIN_ID)"
echo -e "${BLUE}🔗 RPC URL:${NC} $RPC_URL"

if [[ -n "$EXPLORER_URL" && -n "$CONTRACT_ADDRESS" ]]; then
    echo -e "${BLUE}🔍 Block Explorer:${NC} $EXPLORER_URL/address/$CONTRACT_ADDRESS"
fi

echo ""
echo -e "${YELLOW}💡 Next Steps:${NC}"
echo "   1. Update your frontend .env with the contract address:"
echo "      NEXT_PUBLIC_CONTRACT_ADDRESS=$CONTRACT_ADDRESS"
echo "   2. Update your frontend .env with the RPC URL:"
echo "      NEXT_PUBLIC_RPC_URL=$RPC_URL"
echo "   3. Update your frontend .env with the chain ID:"
echo "      NEXT_PUBLIC_CHAIN_ID=$CHAIN_ID"

if [[ "$NETWORK" == "crossfi-testnet" ]]; then
    echo "   4. Fund your admin/test accounts with CrossFi testnet tokens"
    echo "   5. Visit CrossFi testnet faucet if needed"
    echo "   6. Test the contract functionality"
fi

echo ""

# Save deployment info to file
if [[ -n "$CONTRACT_ADDRESS" ]]; then
    cat > deployment_info.json << EOF
{
  "network": "$NETWORK",
  "chainId": $CHAIN_ID,
  "contractName": "WalkScapeCore",
  "contractAddress": "$CONTRACT_ADDRESS",
  "adminAddress": "${ADMIN_ADDRESS:-"deployer"}",
  "rpcUrl": "$RPC_URL",
  "explorerUrl": "$EXPLORER_URL",
  "deployedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "verified": $VERIFY
}
EOF

    echo -e "${BLUE}📄 Deployment info saved to deployment_info.json${NC}"
fi

# Test basic functionality
if [[ -n "$CONTRACT_ADDRESS" ]]; then
    echo -e "${YELLOW}🧪 Testing basic contract functionality...${NC}"
    
    OWNER=$(cast call $CONTRACT_ADDRESS "owner()" --rpc-url $RPC_URL 2>/dev/null || echo "")
    if [[ -n "$OWNER" ]]; then
        echo -e "${GREEN}✅ Contract is responsive${NC}"
        echo -e "${BLUE}   Owner:${NC} $OWNER"
        
        ARTIFACT_COUNTER=$(cast call $CONTRACT_ADDRESS "artifactCounter()" --rpc-url $RPC_URL 2>/dev/null | cast --to-dec || echo "")
        PET_COUNTER=$(cast call $CONTRACT_ADDRESS "petCounter()" --rpc-url $RPC_URL 2>/dev/null | cast --to-dec || echo "")
        COLONY_COUNTER=$(cast call $CONTRACT_ADDRESS "colonyCounter()" --rpc-url $RPC_URL 2>/dev/null | cast --to-dec || echo "")
        
        echo -e "${BLUE}   Artifact Counter:${NC} $ARTIFACT_COUNTER"
        echo -e "${BLUE}   Pet Counter:${NC} $PET_COUNTER"
        echo -e "${BLUE}   Colony Counter:${NC} $COLONY_COUNTER"
    else
        echo -e "${YELLOW}⚠️  Could not verify contract functionality${NC}"
    fi
fi

echo ""
echo -e "${GREEN}🚀 Deployment process completed successfully!${NC}"
