// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

contract UniSwapV3 is Ownable {

   function getPrice(address poolAddress) external view onlyOwner returns (uint256 price) { 
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
        (uint160 sqrtPriceX96,,,,,,) = pool.slot0();
        return uint(sqrtPriceX96) * (uint(sqrtPriceX96)) * (1e18) >> (96 * 2); 
    }

    function getQuote(address poolAddress, address tokenIn, uint amount) external view onlyOwner returns (uint256 amountB) { 
        (int24 tick,) = OracleLibrary.consult(poolAddress, 60);
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
        address tokenOut = pool.token0();
        if(tokenIn == tokenOut) { 
            tokenOut = pool.token1();
        }
        return OracleLibrary.getQuoteAtTick(tick, uint128(amount), tokenIn, tokenOut);
    }
}
