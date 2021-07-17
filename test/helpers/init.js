/* eslint-disable no-undef */
const setup = async () => {
    const signers = await ethers.getSigners();
    return {
        roles: {
            root: signers[0],
            beneficiary1: signers[1],
            beneficiary2: signers[2],
            others: signers.slice(3)
        },
        data: {}
    };
};

const Token = async (setup) => await ethers.getContractFactory('Token', setup.roles.root);

const IPVC = async (setup) => await ethers.getContractFactory('Controller', setup.roles.root);

module.exports = {setup, Token, IPVC};