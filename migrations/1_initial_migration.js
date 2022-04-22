const flashBot = artifacts.require("FlashBot");
const router = artifacts.require("UniswapV2Router02");

module.exports = function (deployer) {
  deployer.deploy(flashBot);
  deployer.deploy(router);
};
