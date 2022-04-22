pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';

contract UniswapV2Router02 {
    using SafeMath for uint;

   function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn) {
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }
}