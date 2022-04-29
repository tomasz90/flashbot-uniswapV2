var FlashBot = artifacts.require('FlashBot')
var UniswapV2Library = artifacts.require('UniswapV2Library')

module.exports = (deployer) => {
    deployer.deploy(FlashBot)
    deployer.deploy(UniswapV2Library)
}