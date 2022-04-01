// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-periphery/contracts/lens/Quoter.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IQuoterV2.sol";

contract UniSwapV3Quoter {
    struct Quote {
        address pool;
        uint256 amount;
    }

    struct PoolInfo {
        address pool;
        Token token0;
        Token token1;
        uint24 fee;
    }

    struct Token {
        string name;
        address tokenAddress;
        uint8 decimals;
    }

    Quoter quoter = Quoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);

    function getQuote(
        address poolAddress,
        address tokenIn,
        address tokenOut,
        uint256 amount
    ) public returns (Quote memory) {
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
        uint24 fee = pool.fee();
        uint256 amountOut = quoter.quoteExactInputSingle(
            tokenIn,
            tokenOut,
            fee,
            amount,
            0
        );
        return Quote(poolAddress, amountOut);
    }

    function getQuotes(
        address[] memory poolAddresses,
        address[] memory tokenIn,
        address[] memory tokenOut,
        uint256[] memory amounts
    ) public returns (Quote[] memory) {
        Quote[] memory quotes = new Quote[](poolAddresses.length);
        for (uint256 i = 0; i < poolAddresses.length; i++) {
            (Quote memory quote) = getQuote(poolAddresses[i], tokenIn[i], tokenOut[i], amounts[i]);
            quotes[i] = quote;
        }
        return quotes;
    }

    function getPoolsInfo(address[] memory poolAddresses)
        public
        view
        returns (PoolInfo[] memory)
    {
        PoolInfo[] memory infos = new PoolInfo[](poolAddresses.length);
        for (uint256 i = 0; i < poolAddresses.length; i++) {
            address poolAddress = poolAddresses[i];
            IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);

            ERC20 token0ERC20 = ERC20(pool.token0());
            ERC20 token1ERC20 = ERC20(pool.token1());

            Token memory token0 = Token(token0ERC20.name(), address(token0ERC20), token0ERC20.decimals());
            Token memory token1 = Token(token1ERC20.name(), address(token1ERC20), token1ERC20.decimals());

            uint24 fee = pool.fee();
            infos[i] = PoolInfo(
                poolAddress,
                token0,
                token1,
                fee
            );
        }
        return infos;
    }
}

contract ERC20 {
    function name() public view virtual returns (string memory) {}
    function decimals() public view virtual returns (uint8) {}
}
