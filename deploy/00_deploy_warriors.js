/* eslint-disable no-undef */
const addressesPath = "../addresses.json";
const DeployedContracts = require(addressesPath);
const fs = require('fs');
const path = require('path');

module.exports = async ({getNamedAccounts, deployments, network}) => {
    console.log("Deploying contracts on ", network.name);
    const {deploy} = deployments;
    const {deployer} = await getNamedAccounts();
    const {origin} = DeployedContracts[network.name];
    const initialMaxPop = 14020;
    const {address: warriorCoreAddress} = await deploy('WarriorCore', {
        from: deployer,
        args: [initialMaxPop],
        log: true
    });

    const {address: warriorGeneGeneratorAddress} = await deploy('WarriorGeneGenerator', {
        from: deployer,
        args: [warriorCoreAddress],
        log: true
    });

    const warriorInstance = await ethers.getContract('WarriorCore', deployer);
    await warriorInstance.initialize(origin, warriorGeneGeneratorAddress);

    DeployedContracts[network.name].WarriorCore = warriorCoreAddress;
    DeployedContracts[network.name].warriorGeneGeneratorAddress = warriorGeneGeneratorAddress;

    fs.writeFileSync(
        path.resolve(__dirname,addressesPath),
        JSON.stringify(DeployedContracts)
    );

};

module.exports.tags = ['MyContract'];