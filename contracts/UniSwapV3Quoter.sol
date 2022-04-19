// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3FlashCallback.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/Path.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

contract UniSwapV3Quoter is IUniswapV3FlashCallback {

    IQuoter public immutable quoter = IQuoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);
    ISwapRouter public immutable swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    IUniswapV3Factory public immutable uniswapFactory = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);

    
    function getPoolsInfo(address[] memory poolAddresses) public view returns (PoolInfo[] memory) {
        PoolInfo[] memory infos = new PoolInfo[](poolAddresses.length);
        for (uint256 i = 0; i < poolAddresses.length; i++) {
            address poolAddress = poolAddresses[i];
            IUniswapV2Pair pool = IUniswapV2Pair(poolAddress);

            ERC20 token0ERC20 = ERC20(pool.token0());
            ERC20 token1ERC20 = ERC20(pool.token1());

            Token memory token0 = Token(token0ERC20.name(), address(token0ERC20), token0ERC20.decimals());
            Token memory token1 = Token(token1ERC20.name(), address(token1ERC20), token1ERC20.decimals());

            infos[i] = PoolInfo(poolAddress, token0, token1);
        }
        return infos;
    }


    function initFlashSwap(bytes memory path, uint256 amountIn) external {
        (address tokenIn, address tokenOut, uint24 poolFee) = Path.decodeFirstPool(path);
        
        IUniswapV3Pool pool = IUniswapV3Pool(uniswapFactory.getPool(tokenIn, tokenOut, poolFee));

        uint256 amount0 = tokenIn == pool.token0() ? amountIn : 0;
        uint256 amount1 = tokenOut == pool.token0() ? amountIn : 0;
        
        bytes memory data = abi.encode(FlashCallbackData(path, amountIn));

        pool.flash(address(this), amount0, amount1, data);
    }

    function uniswapV3FlashCallback(uint256 fee0, uint256 fee1, bytes calldata data) external override {
        FlashCallbackData memory data = abi.decode(data, (FlashCallbackData));

        uint256 amountOut = multiSwap(data.path, data.amountIn);

        uint256 amountOwned = fee0 != 0 ? fee0 : fee1;
        amountOwned += data.amountIn;

        (address tokenIn,,) = Path.decodeFirstPool(data.path);
        TransferHelper.safeApprove(tokenIn, address(this), amountOwned);
    }
    
    function multiSwap(bytes memory path, uint256 amountIn) public returns(uint256) {
        ISwapRouter.ExactInputParams memory params =
            ISwapRouter.ExactInputParams({
                path: path,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0
            });        
        return swapRouter.exactInput(params);
    }
}

contract ERC20 {
    function name() public view virtual returns (string memory) {}
    function decimals() public view virtual returns (uint8) {}
}

struct PoolInfo {
    address pool;
    Token token0;
    Token token1;
}

struct Token {
    string name;
    address tokenAddress;
    uint8 decimals;
}

struct FlashCallbackData {
    bytes path;
    uint256 amountIn;
}
