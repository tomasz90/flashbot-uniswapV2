// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-periphery/contracts/lens/QuoterV2.sol";
import '@uniswap/v3-periphery/contracts/interfaces/IQuoterV2.sol';

contract UniSwapV3Quoter {

    struct Quote {
        address pool;
        uint256 amount;
    }

    QuoterV2 quoter = QuoterV2(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);

    function getQuote(address poolAddress, uint amountIn) public returns (uint256 amountB) {
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
        address tokenIn =  pool.token0();  
        address tokenOut = pool.token1();
        uint24 fee = pool.fee();
        IQuoterV2.QuoteExactInputSingleParams memory params = 
                IQuoterV2.QuoteExactInputSingleParams(tokenIn, tokenOut, amountIn, fee, 0);
        (uint256 amountOut,,,) = quoter.quoteExactInputSingle(params);
        return amountOut;
    }

    function getQuotes(address[] memory poolAddresses, uint[] memory amountsIn) public returns (Quote[] memory quotes) {
        for (uint i=0; i < poolAddresses.length; i++) {
            quotes[i] = Quote(poolAddresses[i], getQuote(poolAddresses[i], amountsIn[i]));
        }
        return quotes;
    }
}
