const FlashBot = artifacts.require("FlashBot");
const { assertException, errTypes } = require('./exceptions');

contract('FlashBot', (accounts) => {
    let flashBot;

    before(async () => {
        flashBot = await FlashBot.deployed();
    })

    it('Only owner should be able to withdraw', async () => {
        let notOwner = accounts[2];
        let token = '0x0000000000000000000000000000000000000000';
        await assertException(flashBot.withdraw(token, {from: notOwner}), errTypes.revert);
    });

    // it('should init swap', async () => {
    //     let calldata = fs.readFileSync(process.cwd() + "/test/testPayload.txt").toString();
    //     await flashBot.withdraw('0x0000000000000000000000000000000000000000', { gasPrice: 11, gasLimit: 1000000});
    // });
});
 