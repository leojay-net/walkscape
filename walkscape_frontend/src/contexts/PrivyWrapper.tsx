'use client';

import React from 'react';
import { PrivyProvider } from '@privy-io/react-auth';

interface PrivyWrapperProps {
    children: React.ReactNode;
}

export default function PrivyWrapper({ children }: PrivyWrapperProps) {
    const appId = process.env.NEXT_PUBLIC_PRIVY_APP_ID;

    if (!appId) {
        console.error('NEXT_PUBLIC_PRIVY_APP_ID is not set');
        return <div>Error: Privy App ID not configured</div>;
    }

    return (
        <PrivyProvider
            appId={appId}
            config={{
                // Appearance customization
                appearance: {
                    theme: 'dark',
                    accentColor: '#3B82F6',
                    logo: 'https://walkscape.app/icon.png',
                },
                // Login methods
                loginMethods: [
                    'wallet',
                    'email',
                    'sms',
                    'google',
                    'twitter',
                    'discord',
                    'github',
                ],
                // Wallet configuration
                embeddedWallets: {
                    createOnLogin: 'users-without-wallets',
                    requireUserPasswordOnCreate: false,
                },
                // Network configuration for CrossFi
                defaultChain: {
                    id: 4157,
                    name: 'CrossFi Testnet',
                    network: 'crossfi-testnet',
                    nativeCurrency: {
                        name: 'CrossFi',
                        symbol: 'XFI',
                        decimals: 18,
                    },
                    rpcUrls: {
                        default: {
                            http: [process.env.NEXT_PUBLIC_RPC_URL || 'https://rpc.testnet.ms/'],
                        },
                        public: {
                            http: [process.env.NEXT_PUBLIC_RPC_URL || 'https://rpc.testnet.ms/'],
                        },
                    },
                    blockExplorers: {
                        default: {
                            name: 'CrossFi Explorer',
                            url: 'https://explorer.testnet.ms/',
                        },
                    },
                    testnet: true,
                },
                supportedChains: [
                    {
                        id: 4157,
                        name: 'CrossFi Testnet',
                        network: 'crossfi-testnet',
                        nativeCurrency: {
                            name: 'CrossFi',
                            symbol: 'XFI',
                            decimals: 18,
                        },
                        rpcUrls: {
                            default: {
                                http: [process.env.NEXT_PUBLIC_RPC_URL || 'https://rpc.testnet.ms/'],
                            },
                            public: {
                                http: [process.env.NEXT_PUBLIC_RPC_URL || 'https://rpc.testnet.ms/'],
                            },
                        },
                        blockExplorers: {
                            default: {
                                name: 'CrossFi Explorer',
                                url: 'https://explorer.testnet.ms/',
                            },
                        },
                        testnet: true,
                    },
                ],
            }}
        >
            {children}
        </PrivyProvider>
    );
}
