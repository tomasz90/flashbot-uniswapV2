const HDWalletProvider = require("@truffle/hdwallet-provider");
const fs = require("fs");
const MNEMONIC="***REMOVED***"

module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // to customize your Truffle configuration!
    networks: {
        development: {
            host: "127.0.0.1", // Localhost (default: none)
            port: 7546, // Standard Ethereum port (default: none)
            network_id: "*", // Any network (default: none)
            gas: 100000000
        },
        matic: {
            provider: () => new HDWalletProvider(MNEMONIC, 
            "https://matic-mainnet.chainstacklabs.com"),
            network_id: 137,
            confirmations: 2,
            timeoutBlocks: 50,
            skipDryRun: true,
            gas: 1500000,
            gasPrice: 90000000000,
        },
        ma: { // matic archive for debugging purpose
            provider: () => new HDWalletProvider(MNEMONIC, 
            "***REMOVED***"),
            network_id: 137,
            confirmations: 2,
            timeoutBlocks: 200,
            skipDryRun: true,
            gas: 6000000,
            gasPrice: 25000000000,
        },
        bsc: {
        provider: () => new HDWalletProvider(MNEMONIC, 
        "***REMOVED***/archive"),
        network_id: 56,
        confirmations: 2,
        timeoutBlocks: 200,
        skipDryRun: true,
        gas: 10000000,
        gasPrice: 5000000000,
        }
    },
    compilers: {
        solc: {
            version: '0.7.6'
        }
    }
};
