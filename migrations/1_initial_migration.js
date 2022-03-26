const UniSwapV3 = artifacts.require("UniSwapV3");

module.exports = function (deployer) {
  deployer.deploy(UniSwapV3);
};
