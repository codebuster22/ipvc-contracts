/* eslint-disable no-undef */
const { expect } = require("chai");
const { constants } = require("@openzeppelin/test-helpers");
const init = require("../helpers/init");

const deploy = async () => {
    const setup = await init.setup();

    setup.Warriors = await init.Warriors(setup);

    setup.IPVC = await init.IPVC(setup);

    return setup;
};

describe("Contract: Warriors", async () => {
    let setup;
    context("Deploy Contract", async () => {
        before("!! init setup", async () => {
            setup = await deploy();
            setup.ipvc = await setup.IPVC.deploy();
        });
        context("controller address is zero address", async () => {
            it(">> reverts", async () => {
                await expect(setup.Warriors.deploy(constants.ZERO_ADDRESS)).to.revertedWith(
                    "Warriors: Controller address cannot be zero address"
                );
            });
        });
        context("controller address is valid", async () => {
            it(">> deploy token contract", async () => {
                setup.warriors = await setup.Warriors.deploy(setup.roles.root.address);
                expect(await setup.warriors.token_version()).to.equal("0.1.0-beta");
            });
        });
    });
    context(">> generateWarrior", async () => {
        context("gene is 0", async () => {
            it("reverts", async () => {
                await expect(
                    setup.warriors.connect(setup.roles.root).generateWarrior(0, setup.roles.root.address)
                ).to.revertedWith("Warriors: no warrior without gene");
            });
        });
        context("owner is zero address", async () => {
            it("reverts", async () => {
                const gene = setup.generateRandomGene();
                await expect(
                    setup.warriors.connect(setup.roles.root).generateWarrior(gene, constants.ZERO_ADDRESS)
                ).to.revertedWith("Warriors: no warrior can be assigned to zero address");
            });
        });
        context("caller is not controller", async () => {
            it("reverts", async () => {
                const gene = setup.generateRandomGene();
                await expect(
                    setup.warriors
                        .connect(setup.roles.beneficiary1)
                        .generateWarrior(gene, setup.roles.beneficiary1.address)
                ).to.revertedWith("Warriors: Only controller can access this function");
            });
        });
        it("generate warrior with correct values", async () => {
            setup.data.gene1 = setup.generateRandomGene();
            await expect(
                setup.warriors
                    .connect(setup.roles.root)
                    .generateWarrior(setup.data.gene1, setup.roles.beneficiary1.address)
            )
                .to.emit(setup.warriors, "WarriorGenerated")
                .withArgs(setup.roles.beneficiary1.address, "0");
            expect(await setup.warriors.ownerOf(0)).to.equal(setup.roles.beneficiary1.address);
            expect((await setup.warriors.balanceOf(setup.roles.beneficiary1.address)).toString()).to.equal("1");
        });
    });
    context(">> updateController", async () => {
        context("caller is not controller", async () => {
            it("reverts", async () => {
                await expect(
                    setup.warriors.connect(setup.roles.beneficiary1).updateController(setup.roles.beneficiary1.address)
                ).to.revertedWith("Warriors: Only controller can access this function");
            });
        });
        context("controller is zero address", async () => {
            it("reverts", async () => {
                await expect(
                    setup.warriors.connect(setup.roles.root).updateController(constants.ZERO_ADDRESS)
                ).to.revertedWith("Warriors: controller cannot be address zero");
            });
        });
        context("caller is controller", async () => {
            it("reverts", async () => {
                await setup.warriors.connect(setup.roles.root).updateController(setup.roles.beneficiary1.address);
                expect(await setup.warriors.controller()).to.equal(setup.roles.beneficiary1.address);
            });
        });
    });
    context("# getter functions", async () => {
        context(">> getWarrior", async () => {
            it("returns correct warrior", async () => {
                expect((await setup.warriors.getWarrior(0)).toString()).to.equal(setup.data.gene1);
            });
            it("reverts when warrior doesn't exists", async () => {
                await expect(setup.warriors.getWarrior(1)).to.revertedWith("Warriors: warrior does not exist");
            });
        });
        context(">> total warriors", async () => {
            it("returns correct", async () => {
                expect((await setup.warriors.warriorCounter()).toString()).to.equal("1");
            });
        });
    });
});
