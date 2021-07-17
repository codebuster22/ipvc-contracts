/* eslint-disable no-undef */
const {expect} = require('chai');
const {constants} = require('@openzeppelin/test-helpers');
const init = require('../helpers/init');

const deploy = async () => {
    const setup = await init.setup();

    setup.Token = await init.Token(setup);

    setup.IPVC = await init.IPVC(setup);

    return setup;
};

describe("Contract: Token", async () => {
    let setup;
    context("Deploy Token COntract", async () => {
        before("!! init setup", async () => {
            setup = await deploy();
            setup.ipvc = await setup.IPVC.deploy();
        });
        context("controller address is zero address", async () => {
            it(">> reverts", async () => {
                await expect(setup.Token.deploy(constants.ZERO_ADDRESS))
                    .to
                    .revertedWith("Token: Controller address cannot be zero address");
            });
        });
        context("controller address is valid", async () => {
            it(">> deploy token contract", async () => {
                setup.token = await setup.Token.deploy(setup.ipvc.address);
                expect(await setup.token.token_version()).to.equal("0.1.0-beta");
            });
        });
    });
});