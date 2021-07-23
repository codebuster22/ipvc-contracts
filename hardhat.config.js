// eslint-disable
require("@nomiclabs/hardhat-waffle");
require('solidity-coverage');

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => { // eslint-disable-line
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
    solidity: {
        compilers: [
            {
                version: "0.8.6"
            },
            {
                version: "0.8.4"
            }
        ]
    },
};

