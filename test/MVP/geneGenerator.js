/* eslint-disable no-undef */
const { expect } = require("chai");
const { constants } = require("@openzeppelin/test-helpers");

const init = require("../helpers/init");

const deploy = async () => {
    const setup = await init.setup();

    setup.Warriors = await init.Warriors(setup);

    setup.Controller = await init.Controller(setup);

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
            setup.geneGenerator = await setup.GeneGenerator.deploy();
            expect(await setup.geneGenerator.controller()).to.equal(setup.roles.root.address);
        });
    });
    context(">> generate genes", async () => {
        it("generates gene with 5 attributes", async () => {
            const metadata = ethers.utils.id(Math.random().toString());
            expect((await setup.geneGenerator.geneGenerator(metadata)).toString().length).to.equal(10);
        });
    });
    context(">> controller functionality", async () => {
        context("setAttributes", async()=> {
            it("updates attributes when valid input given", async ()=>{
                await setup.geneGenerator.connect(setup.roles.root).setTotalGeneAttributes(6);
                expect((await setup.geneGenerator.totalGeneAttributes()).toString()).to.equal("6");
                expect((await setup.geneGenerator.geneModulus()).toString()).to.equal((10**12).toString());
            });
            context("attributes less than current", async () => {
                it("reverts", async () => {
                    await expect(setup.geneGenerator.setTotalGeneAttributes(4)).to.be.revertedWith("WarriorGeneGenerator: cannot decrease gene attributes");
                });
            });
        });
        context("setController", async () => {
            it("updates wwith valid new controller address", async () => {
                await setup.geneGenerator.connect(setup.roles.root).setController(setup.roles.beneficiary1.address);
                expect(await setup.geneGenerator.controller()).to.equal(setup.roles.beneficiary1.address);
            });
            context("new controller address is zero address", async () => {
                it("reverts", async () => {
                    await expect(setup.geneGenerator.connect(setup.roles.beneficiary1).setController(constants.ZERO_ADDRESS)).to.be.revertedWith("WarriorGeneGenerator: new controller cannot be zero");
                });
            });
        });
    });
});