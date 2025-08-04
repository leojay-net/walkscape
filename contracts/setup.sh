#!/bin/bash

# Simple setup script for WalkScape contracts
echo "🔧 Setting up WalkScape contracts..."

# Create lib directory if it doesn't exist
mkdir -p lib

# Download OpenZeppelin contracts directly
if [ ! -d "lib/openzeppelin-contracts" ]; then
    echo "📦 Downloading OpenZeppelin contracts..."
    curl -L https://github.com/OpenZeppelin/openzeppelin-contracts/archive/refs/tags/v5.0.0.tar.gz | tar -xz -C lib/
    mv lib/openzeppelin-contracts-5.0.0 lib/openzeppelin-contracts
    echo "✅ OpenZeppelin contracts installed"
else
    echo "✅ OpenZeppelin contracts already installed"
fi

# Build the contracts
echo "🔨 Building contracts..."
forge build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "🚀 Ready to deploy! Use:"
    echo "  export PRIVATE_KEY=0x..."
    echo "  make crossfi-testnet"
else
    echo "❌ Build failed. Please check for errors."
fi
