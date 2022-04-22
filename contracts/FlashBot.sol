// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol';

import './UniswapV2Router02.sol';
import './ConstantsLibrary.sol';

contract FlashBot is IUniswapV2Callee, Ownable {
    
    IUniswapV2Factory public immutable uniswapFactory = IUniswapV2Factory(ConstantsLibrary.factory);
    UniswapV2Router02 public immutable uniswapRouter = UniswapV2Router02(ConstantsLibrary.router);

    function getReservesInfo(address[] memory pools) public view returns (ReserveInfo[] memory) {
        ReserveInfo[] memory infos = new ReserveInfo[](pools.length);
        for (uint256 i = 0; i < pools.length; i++) {
            IUniswapV2Pair pool = IUniswapV2Pair(pools[i]);
            (uint256 reserveAmount0, uint256 reserveAmount1, ) = pool
                .getReserves();

            ERC20 erc20_0 = ERC20(pool.token0());
            ERC20 erc20_1 = ERC20(pool.token1());

            Token memory token0 = Token(erc20_0.name(), address(erc20_0), erc20_0.decimals());
            Token memory token1 = Token(erc20_1.name(), address(erc20_1), erc20_1.decimals());

            Reserve memory reserve0 = Reserve(token0, reserveAmount0);
            Reserve memory reserve1 = Reserve(token1, reserveAmount1);

            infos[i] = ReserveInfo(address(pool), reserve0, reserve1);
        }
        return infos;
    }

    function initSwap(uint amountIn, bytes calldata data) external onlyOwner {
        (address[] memory path) = abi.decode(data, (address[]));
        
        IUniswapV2Pair pool = IUniswapV2Pair(uniswapFactory.getPair(path[0], path[path.length-1]));

        (uint amount0Out, uint amount1Out) = pool.token0() == path[0] ? (amountIn, 0) : (uint(0), amountIn);

        pool.swap(amount0Out, amount1Out, address(this), data);
    }

    // this function is called after triggering flashswap
    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external override {
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        assert(msg.sender == IUniswapV2Factory(uniswapFactory).getPair(token0, token1));

        (address[] memory path) = abi.decode(data, (address[]));
        IUniswapV2Pair firstPool = IUniswapV2Pair(msg.sender);

        (uint reserve0, uint reserve1,) = firstPool.getReserves();
        (reserve0, reserve1) = token0 == path[0] ? (reserve0, reserve1) : (reserve1, reserve0);

        uint amountIn = amount0 != 0 ? amount0 : amount1;
        uint amountOwed = uniswapRouter.getAmountIn(amountIn, reserve0, reserve1);

        ERC20 borrowedToken = ERC20(path[0]);
        borrowedToken.approve(address(uniswapRouter), amountIn);

        uniswapRouter.swapExactTokensForTokens(
            amountIn,
            0, // todo: replace with amountOwed, to tests is fine
            path,
            address(this),
            block.timestamp + 60
        );

        address tokenOwed = path[path.length-1];
        ERC20(tokenOwed).transfer(msg.sender, amountOwed);
    }

    function withdraw(address token) external onlyOwner {
        ERC20 erc20 = ERC20(token);
        uint256 balance = erc20.balanceOf(address(this));
        erc20.transfer(owner(), balance);
    }
}

struct ReserveInfo {
    address poolAddress;
    Reserve reserve0;
    Reserve reserve1;
}

struct Reserve {
    Token token;
    uint256 reserve;
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
