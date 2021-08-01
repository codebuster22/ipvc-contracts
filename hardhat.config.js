// eslint-disable
require("dotenv").config({ path: "./.env" });
require("solidity-coverage");
require("@nomiclabs/hardhat-web3");
require("hardhat-deploy");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

const { INFURA_KEY, MNEMONIC, ETHERSCAN_API_KEY, PK } = process.env;
const DEFAULT_MNEMONIC = "hello darkness my old friend";

const sharedNetworkConfig = {};
if (PK) {
    sharedNetworkConfig.seeds = [PK];
} else {
    sharedNetworkConfig.accounts = {
        mnemonic: MNEMONIC || DEFAULT_MNEMONIC,
    };
}

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
    // eslint-disable-line
    const accounts = await ethers.getSigners(); // eslint-disable-line

    for (const account of accounts) {
        console.log(account.address);
    }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    paths: {
        artifacts: "build/artifacts",
        cache: "build/cache",
        deploy: "deploy",
        sources: "contracts",
    },
    defaultNetwork: "hardhat",
    networks: {
        localhost: {
            ...sharedNetworkConfig,
            blockGasLimit: 100000000,
            gas: 2000000,
            saveDeployments: true,
        },
        hardhat: {
            ...sharedNetworkConfig,
            blockGasLimit: 100000000,
            gas: 2000000,
            saveDeployments: true,
        },
        mainnet: {
            ...sharedNetworkConfig,
            url: `https://mainnet.infura.io/v3/${INFURA_KEY}`,
            saveDeployments: true,
        },
        rinkeby: {
            ...sharedNetworkConfig,
            url: `https://rinkeby.infura.io/v3/${INFURA_KEY}`,
            saveDeployments: true,
        },
    },
    solidity: {
        compilers: [
            {
                version: "0.8.6",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
            {
                version: "0.8.4",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
        ],
    },
    namedAccounts: {
        deployer: 0,
        prime: 1,
        beneficiary: 2,
    },
    etherscan: {
        // Your API key for Etherscan
        // Obtain one at https://etherscan.io/
        apiKey: ETHERSCAN_API_KEY,
    },
};
