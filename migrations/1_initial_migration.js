const UniSwapV3Quoter = artifacts.require("UniSwapV3Quoter");

module.exports = function (deployer) {
  deployer.deploy(UniSwapV3Quoter);
};
