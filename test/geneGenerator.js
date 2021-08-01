/* eslint-disable no-undef */
const { expect } = require("chai");
const { constants } = require("@openzeppelin/test-helpers");

const init = require("./helpers/init");

const deploy = async () => {
    const setup = await init.setup();

    setup.Warriors = await init.Warriors(setup);

    setup.GeneGenerator = await init.GeneGenerator(setup);

    return setup;
};

describe("Contract: WarriorGeneGenerator", async () => {
    let setup;
    context(">> Deploy Gene Generator", async () => {
        before("!! setup", async () => {
            setup = await deploy();
        });
        it("deploys gene generator", async () => {
            setup.geneGenerator = await setup.GeneGenerator.deploy(setup.roles.root.address);
            expect(await setup.geneGenerator.core()).to.equal(setup.roles.root.address);
        });
    });
    context(">> generate genes", async () => {
        it("generates gene with 5 attributes", async () => {
            const metadata = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(Math.random().toString()));
            expect((await setup.geneGenerator.generateGene(1, metadata)).toString().length).to.equal(76);
        });
        context("msg.sender is not core address", async ()=> {
            it("reverts", async () => {
                const metadata = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(Math.random().toString()));
                await expect(
                    setup.geneGenerator.connect(setup.roles.beneficiary1).generateGene(1, metadata)
                ).to.be.revertedWith("WarriorGeneGenerator: only core functionality");
            });
        });
    });
    context("setCore", async () => {
        context("new core address is zero address", async () => {
            it("reverts", async () => {
                await expect(
                    setup.geneGenerator.connect(setup.roles.root).setCore(constants.ZERO_ADDRESS)
                ).to.be.revertedWith("WarriorGeneGenerator: new core cannot be zero");
            });
        });
        context("valid new core address", async () => {
            it("updates wwith valid new core address", async () => {
                await setup.geneGenerator.connect(setup.roles.root).setCore(setup.roles.beneficiary1.address);
                expect(await setup.geneGenerator.core()).to.equal(setup.roles.beneficiary1.address);
            });
        });
    });
});
