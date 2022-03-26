// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";

struct PairsInfo {
    address pairAddress;
    address token0;
    address token1;
    uint24 fee;
}

contract UniSwapV3 is Ownable {

   function getPrice(address poolAddress) external view returns (uint256 price) { 
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
        (uint160 sqrtPriceX96,,,,,,) = pool.slot0();
        return uint(sqrtPriceX96).mul(uint(sqrtPriceX96)).mul(1e18) >> (96 * 2); 
        }


    function getQuote(address tokenA, uint amountA, address tokenB) public view override returns (uint256 amountB) { 
        int24 tick = OracleLibrary.consult(factory.getPool(tokenIn, tokenOut, fee), 60); 
        return OracleLibrary.getQuoteAtTick(tick, uint128(amountA), tokenA, tokenB); 
        }
}
