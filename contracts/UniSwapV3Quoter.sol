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
        string tokenName0;
        string tokenName1;
        address tokenAddress0;
        address tokenAddress1;
        uint24 fee;
    }

    Quoter quoter = Quoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);

    function getQuote(
        address poolAddress,
        address tokenIn,
        address tokenOut,
        uint256 amount
    ) public returns (uint256) {
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
        uint24 fee = pool.fee();
        return quoter.quoteExactInputSingle(tokenIn, tokenOut, fee, amount, 0);
    }

    function getQuotes(
        address[] memory poolAddresses,
        address[] memory tokenIn,
        address[] memory tokenOut,
        uint256[] memory amounts
    ) public returns (Quote[] memory) {
        Quote[] memory quotes = new Quote[](poolAddresses.length);
        for (uint256 i = 0; i < poolAddresses.length; i++) {
            uint256 amountOut = getQuote(
                poolAddresses[i],
                tokenIn[i],
                tokenOut[i],
                amounts[i]
            );
            quotes[i] = Quote(poolAddresses[i], amountOut);
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
            address tokenAddress0 = pool.token0();
            address tokenAddress1 = pool.token1();
            string memory tokenName0 = ERC20(tokenAddress0).name();
            string memory tokenName1 = ERC20(tokenAddress1).name();
            uint24 fee = pool.fee();
            infos[i] = PoolInfo(
                poolAddress,
                tokenName0,
                tokenName1,
                tokenAddress0,
                tokenAddress1,
                fee
            );
        }
        return infos;
    }
}

contract ERC20 {
    function name() public view virtual returns (string memory) {}
}
