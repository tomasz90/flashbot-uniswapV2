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
        string token0;
        string token1;
    }

    Quoter quoter = Quoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);

     function getQuote(address poolAddress, uint amount) public returns (uint256) {
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
        uint256 amountIn = amount;
        address tokenIn = pool.token0();
        address tokenOut = pool.token1();
        uint24 fee = pool.fee();
        return quoter.quoteExactInputSingle(tokenIn, tokenOut, fee, amountIn, 0);
    }

    function getQuotes(address[] memory poolAddresses, uint[] memory amountsIn) public returns (Quote[] memory quotes) {
        for (uint i=0; i < poolAddresses.length; i++) {
            quotes[i] = Quote(poolAddresses[i], getQuote(poolAddresses[i], amountsIn[i]));
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
            string memory token0 = ERC20(pool.token0()).name();
            string memory token1 = ERC20(pool.token1()).name();
            infos[i] = PoolInfo(poolAddress, token0, token1);
        }
        return infos;
    }
}

contract ERC20 {
    function name() public view virtual returns (string memory) {}
}
