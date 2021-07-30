/* eslint-disable no-undef */
const setup = async () => {
    const signers = await ethers.getSigners();
    return {
        roles: {
            root: signers[0],
            beneficiary1: signers[1],
            beneficiary2: signers[2],
            origin: signers[3],
            others: signers.slice(4)
        },
        generateRandomGene,
        data: {},
    };
};

const Warriors = async (setup) => await ethers.getContractFactory("Warriors", setup.roles.root);

const Controller = async (setup) => await ethers.getContractFactory("Controller", setup.roles.root);

const GeneGenerator = async (setup) => await ethers.getContractFactory("WarriorGeneGenerator", setup.roles.root);

const generateRandomDigits = (numberOfDigits, maxValue) => Math.floor(Math.random() * 10 ** numberOfDigits) % maxValue;

const generateRandomGene = () => {
    const country = generateRandomDigits(3, 200);
    const layer1 = generateRandomDigits(2, 100);
    const layer2 = generateRandomDigits(2, 100);
    const layer3 = generateRandomDigits(2, 100);
    const layer4 = generateRandomDigits(2, 100);
    const layer5 = generateRandomDigits(2, 100);
    return `${country}${layer1}${layer2}${layer3}${layer4}${layer5}`;
};

module.exports = { setup, Warriors, Controller, GeneGenerator };
