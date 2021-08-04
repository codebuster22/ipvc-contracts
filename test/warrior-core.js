/* eslint-disable no-undef */
const { expect, use } = require("chai");
const { constants, time, BN } = require("@openzeppelin/test-helpers");
const { getBytes32FromHash, getHashFromBytes32 } = require('./helpers/herlpers');
const {solidity} = require('ethereum-waffle');
const init = require("./helpers/init");
use(solidity);

const deploy = async () => {
    const setup = await init.setup();

    setup.Warriors = await init.Warriors(setup);

    setup.GeneGenerator = await init.GeneGenerator(setup);

    return setup;
};

const generateMetadata = () => ethers.utils.keccak256(ethers.utils.toUtf8Bytes(Math.random().toString()));

const logisticsCalculation = (startingPop, growthRate) => {
    const percent = startingPop/1000;
    const nextGenMaxPopPercent = growthRate*(percent)*(1-percent);
    const nextGenPop = nextGenMaxPopPercent*1000;
    return Math.floor(nextGenPop);
};

describe("Contract: WarriorCore", async () => {
    let setup;
    let metadata;
    let startBlockNumer = await ethers.provider.getBlockNumber();
    let hashes = [];
    let invalid_warrior = 100;
    let initialMaxPopulation = 14020;
    let initialMaxPopulationTest = 2;
    context("Deploy & Initialize Contract", async () => {
        before("!! setup and deploy controller", async () => {
            setup = await deploy();
            setup.warriors = await setup.Warriors.deploy(initialMaxPopulation);
            setup.geneGenerator = await setup.GeneGenerator.deploy(setup.warriors.address);
        });
        context("Invalid parameters", async () => {
            it("reverts when origin address zero", async () => {
                await expect(
                    setup.warriors
                        .connect(setup.roles.root)
                        .initialize(constants.ZERO_ADDRESS, setup.geneGenerator.address)
                ).to.revertedWith("Controller: zero address not allowed");
            });
            it("reverts when warrior gene generator contract address zero", async () => {
                await expect(
                    setup.warriors
                        .connect(setup.roles.root)
                        .initialize(setup.roles.origin.address, constants.ZERO_ADDRESS)
                ).to.revertedWith("Controller: zero address not allowed");
            });
        });
        context("valid paramters", async () => {
            it("initializes controller", async () => {
                await setup.warriors
                    .connect(setup.roles.root)
                    .initialize(setup.roles.origin.address, setup.geneGenerator.address);
                expect(await setup.warriors.isInitialized()).to.equal(true);
            });
        });
        context("cannot initialize again", async () => {
            it("reverts", async () => {
                await expect(
                    setup.warriors
                        .connect(setup.roles.root)
                        .initialize(setup.roles.origin.address, setup.geneGenerator.address)
                ).to.revertedWith("Controller: already initialized");
            });
        });
    });
    context(">> generateWarrior", async () => {
        context("generate first warrior", async () => {
            context("invalid parameters", async () => {
                it("reverts when signature length is incorrect", async () => {
                    const to = setup.warriors.address;
                    const from = setup.roles.beneficiary1.address;
                    metadata = generateMetadata();
                    const messageHash = await setup.warriors.generateHash(to, from, metadata);
                    const signature = await setup.roles.root.signMessage(ethers.utils.arrayify(messageHash));
                    await expect(
                        setup.warriors
                            .connect(setup.roles.beneficiary1)
                            .generateWarrior(setup.roles.beneficiary1.address, metadata, signature.slice(0, 10))
                    ).to.revertedWith("SignatureHelper: invalid signature length");
                });
                it("reverts when signature is incorrect", async () => {
                    const to = setup.warriors.address;
                    const from = setup.roles.beneficiary1.address;
                    const messageHash = await setup.warriors.generateHash(to, from, metadata);
                    const signature = await setup.roles.root.signMessage(ethers.utils.arrayify(messageHash));
                    await expect(
                        setup.warriors
                            .connect(setup.roles.beneficiary1)
                            .generateWarrior(setup.roles.beneficiary1.address, metadata, signature)
                    ).to.revertedWith("Controller: invalid origin");
                });
            });
            context("valid origin signature but before time", async () => {
                it("success", async () => {
                    const to = setup.warriors.address;
                    const from = setup.roles.beneficiary1.address;
                    const messageHash = await setup.warriors.generateHash(to, from, metadata);
                    const signature = await setup.roles.origin.signMessage(ethers.utils.arrayify(messageHash));
                    await expect(
                        setup.warriors
                            .connect(setup.roles.beneficiary1)
                            .generateWarrior(setup.roles.beneficiary1.address, metadata, signature)
                    ).to.revertedWith("Controller: wait for next generation warriors to arrive");
                });
            });
            context("valid signature but metadata is zero", async () => {
                it("reverts", async () => {
                    await time.advanceBlockTo((await time.latestBlock()).add(new BN(500)));
                    const to = setup.warriors.address;
                    const from = setup.roles.beneficiary1.address;
                    const messageHash = await setup.warriors.generateHash(to, from, constants.ZERO_BYTES32);
                    const signature = await setup.roles.origin.signMessage(ethers.utils.arrayify(messageHash));
                    await expect(
                        setup.warriors
                            .connect(setup.roles.beneficiary1)
                            .generateWarrior(setup.roles.beneficiary1.address, constants.ZERO_BYTES32, signature)
                    ).to.revertedWith("Warriors: cannot mint warrior without attributes");
                });
            });
            context("valid signature but owner address is zero", async () => {
                it("reverts", async () => {
                    await time.advanceBlockTo((await time.latestBlock()).add(new BN(500)));
                    const to = setup.warriors.address;
                    const messageHash = await setup.warriors.generateHash(to, constants.ZERO_ADDRESS, metadata);
                    const signature = await setup.roles.origin.signMessage(ethers.utils.arrayify(messageHash));
                    await expect(
                        setup.warriors
                            .connect(setup.roles.beneficiary1)
                            .generateWarrior(constants.ZERO_ADDRESS, metadata, signature)
                    ).to.revertedWith("Warriors: no warrior can be assigned to zero address");
                });
            });
            context("valid origin signature", async () => {
                it("success", async () => {
                    const to = setup.warriors.address;
                    const from = setup.roles.beneficiary1.address;
                    const messageHash = await setup.warriors.generateHash(to, from, metadata);
                    const signature = await setup.roles.origin.signMessage(ethers.utils.arrayify(messageHash));
                    await expect(
                        setup.warriors
                            .connect(setup.roles.beneficiary1)
                            .generateWarrior(setup.roles.beneficiary1.address, metadata, signature)
                    ).to.emit(setup.warriors, "WarriorGenerated");
                });
            });
        });
        context("generate second warrior", async () => {
            context("metadata already used", async () => {
                it("reverts", async () => {
                    const to = setup.warriors.address;
                    const from = setup.roles.beneficiary1.address;
                    const messageHash = await setup.warriors.generateHash(to, from, metadata);
                    const signature = await setup.roles.origin.signMessage(ethers.utils.arrayify(messageHash));
                    await expect(
                        setup.warriors
                            .connect(setup.roles.beneficiary1)
                            .generateWarrior(setup.roles.beneficiary1.address, metadata, signature)
                    ).to.be.revertedWith("WarriorCore: metadata already used");
                });
            });
            context("metadata not used", async () => {
                it("reverts", async () => {
                    const to = setup.warriors.address;
                    const from = setup.roles.beneficiary1.address;
                    metadata = generateMetadata();
                    const messageHash = await setup.warriors.generateHash(to, from, metadata);
                    const signature = await setup.roles.origin.signMessage(ethers.utils.arrayify(messageHash));
                    await expect(
                        setup.warriors
                            .connect(setup.roles.beneficiary1)
                            .generateWarrior(setup.roles.beneficiary1.address, metadata, signature)
                    ).to.emit(setup.warriors, "WarriorGenerated");
                });
            });
        });
    });
    context(">> getWarrior", async () => {
        context("warrior doesn't exists", async () => {
            it("reverts", async () => {
                await expect(setup.warriors.getWarrior(invalid_warrior)).to.be.revertedWith("Warriors: warrior does not exist");
            });
        });
        context("warrior exists", async () => {
            it("success", async () => {
                expect(
                    (await setup.warriors.getWarrior(0)).toString().length
                ).to.equal(76);
            });
        });
    });
    context(">> getWarriorGeneration", async () => {
        it("returns correct generation for a warrior", async () => {
            expect(
                (await setup.warriors.getWarriorGeneration(0)).toString()
            ).to.equal("0");
        });
    });
    context(">> admin function", async () => {
        context("updateOrigin", async () => {
            it("reverts when not called by admin", async () => {
                await expect(
                    setup.warriors.connect(setup.roles.beneficiary1).setOrigin(setup.roles.others[0].address)
                ).to.revertedWith("Controller: only admin functionality");
            });
            it("reverts when new origin address is zero", async () => {
                await expect(
                    setup.warriors.connect(setup.roles.root).setOrigin(constants.ZERO_ADDRESS)
                ).to.revertedWith("Controller: origin cannot be zero address");
            });
            it("updates when called by admin", async () => {
                await setup.warriors.connect(setup.roles.root).setOrigin(setup.roles.others[0].address);
                expect(await setup.warriors.origin()).to.equal(setup.roles.others[0].address);
            });
        });
        context("updateGeneGenerator", async () => {
            before("!! deploy new geneGenerator", async () => {
                setup.data.geneGenerator = await setup.GeneGenerator.deploy(setup.warriors.address);
            });
            it("reverts when not called by admin", async () => {
                await expect(
                    setup.warriors.connect(setup.roles.beneficiary1).setGeneGenerator(setup.data.geneGenerator.address)
                ).to.revertedWith("Controller: only admin functionality");
            });
            it("reverts when new origin address is zero", async () => {
                await expect(
                    setup.warriors.connect(setup.roles.root).setGeneGenerator(constants.ZERO_ADDRESS)
                ).to.revertedWith("Controller: gene generator cannot be zero address");
            });
            it("updates when called by admin", async () => {
                await setup.warriors.connect(setup.roles.root).setGeneGenerator(setup.data.geneGenerator.address);
                expect(await setup.warriors.warriorGeneGeneratorContract()).to.equal(setup.data.geneGenerator.address);
            });
        });
        context("registerAssets", async () => {
            before("!! generate hash", async () => {
                const hash = getBytes32FromHash("QmWmyoMoctfbAaiEs2G46gpeUmhqFRDW6KWo64y5r581Vz");
                for(let i = 0; i < 20; i++){
                    hashes.push(hash);
                }
                expect(hashes.length).to.equal(20);
            });
            context("caller is not admin", async () => {
                it("reverts asset", async () => {
                    await expect(
                        setup.warriors.connect(setup.roles.beneficiary1).registerAsset(1, hashes, 0)
                    ).to.be.revertedWith("Controller: only admin functionality");
                });
            });
            context("caller is admin", async () => {
                it("registers asset", async () => {
                    let totalGasCost = new BN(0);
                    let j = 0;
                    for(j; j < 2; j++){
                        for(let i = 0; i<4; i++){
                            const estimate = (await setup.warriors.estimateGas.registerAsset(i, hashes, j).toString());
                            totalGasCost = totalGasCost.add(new BN(estimate));
                            await expect(
                                setup.warriors.connect(setup.roles.root).registerAsset(i, hashes, j)
                            ).to.emit(setup.warriors, "AssetForLayerRegistered");
                        }
                    }
                    console.log("Gas for ",hashes.length," ",totalGasCost.toString());
                });
            });
        });
    });
    context("reading asset data", async () => {
        let filter;
        before("!! set filers for events", async ( ) => {
            filter = setup.warriors.filters.AssetRegistered();
        });
        it("filters assets", async () => {
            let assets = {};
            setup.warriors.queryFilter(filter, startBlockNumer).then(
                events => {
                    events.forEach(
                        event => assets[event.args[0].toString()] = getHashFromBytes32(event.args[1])
                    );
                }
            ).then(() => {
                const gen0s = Object.keys(assets).filter(
                    assetId => assetId.length <= 4
                );
                const gen1s = Object.keys(assets).filter(
                    assetId => assetId.length >= 5 && parseInt(assetId.slice(0,assetId.length-4)) == 1
                );
            });
        });
    });
    context("minting last warrior for generation", async () => {
        let startingPop = 2;
        let growthRate = 3.91;
        before("!! deploy and set initial conditions", async () => {
            setup = await deploy();
            setup.warriors = await setup.Warriors.deploy(initialMaxPopulationTest);
            setup.geneGenerator = await setup.GeneGenerator.deploy(setup.warriors.address);
            await time.advanceBlockTo((await time.latestBlock()).add(new BN(500)));
            await setup.warriors
                .connect(setup.roles.root)
                .initialize(setup.roles.origin.address, setup.geneGenerator.address);
            const to = setup.warriors.address;
            const from = setup.roles.beneficiary1.address;
            const messageHash = await setup.warriors.generateHash(to, from, metadata);
            const signature = await setup.roles.origin.signMessage(ethers.utils.arrayify(messageHash));
            await expect(
                setup.warriors
                    .connect(setup.roles.beneficiary1)
                    .generateWarrior(setup.roles.beneficiary1.address, metadata, signature)
            ).to.emit(setup.warriors, "WarriorGenerated");
        });
        context("mint last warrior", async () => {
            it("mints last warrior", async () => {
                const to = setup.warriors.address;
                const from = setup.roles.beneficiary1.address;
                metadata = generateMetadata();
                const messageHash = await setup.warriors.generateHash(to, from, metadata);
                const signature = await setup.roles.origin.signMessage(ethers.utils.arrayify(messageHash));
                await expect(
                    setup.warriors
                        .connect(setup.roles.beneficiary1)
                        .generateWarrior(setup.roles.beneficiary1.address, metadata, signature)
                ).to.emit(setup.warriors, "WarriorGenerated");
            });
            it("inactivates the minitng process", async () => {
                expect(
                    await setup.warriors
                        .connect(setup.roles.beneficiary1)
                        .isActive()
                ).to.equal(false);
            });
            it("set values for next generation", async () => {
                expect(
                    (await setup.warriors
                        .connect(setup.roles.beneficiary1)
                        .currentGeneration()).toString()
                ).to.equal("1");
                expect(
                    (await setup.warriors
                        .connect(setup.roles.beneficiary1)
                        .populationUntilLastGeneration()).toString()
                ).to.equal(startingPop.toString());
                const nextGenPop = logisticsCalculation(startingPop,growthRate);
                expect(
                    (await setup.warriors
                        .connect(setup.roles.beneficiary1)
                        .currentGenerationMaxPopulation()).toString()
                ).to.equal(nextGenPop.toString());
            });
        });
    });
});
