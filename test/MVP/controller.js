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

describe("Contract: Controller", async () => {
    let setup;
    context("Deploy & Initialize Contract", async () => {
        before("!! setup and deploy controller", async () => {
            setup = await deploy();
            setup.controller = await setup.Controller.deploy();
            setup.warriors = await setup.Warriors.deploy(setup.controller.address);
            setup.geneGenerator = await setup.GeneGenerator.deploy();
        });
        context("Invalid parameters", async () => {
            it("reverts when origin address zero", async () => {
                await expect(
                    setup.controller
                        .connect(setup.roles.root)
                        .initialize(constants.ZERO_ADDRESS, setup.warriors.address, setup.geneGenerator.address)
                ).to.revertedWith("Controller: zero address not allowed");
            });
            it("reverts when warrior contract address zero", async () => {
                await expect(
                    setup.controller
                        .connect(setup.roles.root)
                        .initialize(setup.roles.origin.address, constants.ZERO_ADDRESS, setup.geneGenerator.address)
                ).to.revertedWith("Controller: zero address not allowed");
            });
            it("reverts when warrior gene generator contract address zero", async () => {
                await expect(
                    setup.controller
                        .connect(setup.roles.root)
                        .initialize(setup.roles.origin.address, setup.warriors.address, constants.ZERO_ADDRESS)
                ).to.revertedWith("Controller: zero address not allowed");
            });
        });
        context("valid paramters", async () => {
            it("initializes controller", async () => {
                await setup.controller
                    .connect(setup.roles.root)
                    .initialize(setup.roles.origin.address, setup.warriors.address, setup.geneGenerator.address);
                expect((await setup.controller.isInitialized()).toString()).to.equal("1");
            });
        });
    });
    context(">> generateWarrior", async () => {
        context("invalid origin signature", async () => {
            it("reverts", async () => {
                const to = setup.controller.address;
                const from = setup.roles.beneficiary1.address;
                const gene = setup.generateRandomGene();
                let metadata = parseInt(gene).toString(16);
                metadata = "0x" + (metadata.length % 2 == 0 ? metadata : "0" + metadata);
                const messageHash = await setup.controller.generateHash(to, from, metadata);
                const signature = await setup.roles.root.signMessage(ethers.utils.arrayify(messageHash));
                await expect(
                    setup.controller
                        .connect(setup.roles.beneficiary1)
                        .generateWarrior(setup.roles.beneficiary1.address, gene, metadata, signature)
                ).to.revertedWith("Controller: invalid origin");
            });
        });
        context("valid origin signature", async () => {
            it("reverts", async () => {
                const to = setup.controller.address;
                const from = setup.roles.beneficiary1.address;
                const gene = setup.generateRandomGene();
                let metadata = parseInt(gene).toString(16);
                metadata = "0x" + (metadata.length % 2 == 0 ? metadata : "0" + metadata);
                const messageHash = await setup.controller.generateHash(to, from, metadata);
                const signature = await setup.roles.origin.signMessage(ethers.utils.arrayify(messageHash));
                await expect(
                    setup.controller
                        .connect(setup.roles.beneficiary1)
                        .generateWarrior(setup.roles.beneficiary1.address, gene, metadata, signature)
                ).to.emit(setup.warriors, "WarriorGenerated");
            });
        });
    });
    context(">> update", async () => {
        context("updateOrigin", async () => {
            it("reverts when not called by admin", async () => {
                await expect(
                    setup.controller.connect(setup.roles.beneficiary1).updateOrigin(setup.roles.others[0].address)
                ).to.revertedWith("Controller: only admin functionality");
            });
            it("reverts when new origin address is zero", async () => {
                await expect(
                    setup.controller.connect(setup.roles.root).updateOrigin(constants.ZERO_ADDRESS)
                ).to.revertedWith("Controller: origin cannot be zero address");
            });
            it("updates when called by admin", async () => {
                await setup.controller.connect(setup.roles.root).updateOrigin(setup.roles.others[0].address);
                expect(await setup.controller.origin()).to.equal(setup.roles.others[0].address);
            });
        });
        context("updateGeneGenerator", async () => {
            it("reverts when not called by admin", async () => {
                await expect(
                    setup.controller
                        .connect(setup.roles.beneficiary1)
                        .updateGeneGenerator(setup.roles.others[0].address)
                ).to.revertedWith("Controller: only admin functionality");
            });
            it("reverts when new origin address is zero", async () => {
                await expect(
                    setup.controller.connect(setup.roles.root).updateGeneGenerator(constants.ZERO_ADDRESS)
                ).to.revertedWith("Controller: gene generator cannot be zero address");
            });
            it("updates when called by admin", async () => {
                await setup.controller.connect(setup.roles.root).updateGeneGenerator(setup.roles.others[1].address);
                expect(await setup.controller.warriorGeneGeneratorContract()).to.equal(setup.roles.others[1].address);
            });
        });
    });
});
