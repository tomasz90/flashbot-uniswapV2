// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol';
import './UniswapV2Router02.sol';

contract FlashBot is IUniswapV2Callee, Ownable {
    
    IUniswapV2Factory public immutable uniswapFactory = IUniswapV2Factory(0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32);
    UniswapV2Router02 public immutable uniswapRouter = UniswapV2Router02(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);

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

    function initSwap(uint amountIn, bytes calldata path) external onlyOwner {
        (address[] memory tokenIn, address[] memory tokenOut) = abi.decode(path, (address[], address[]));
        
        IUniswapV2Pair pool = IUniswapV2Pair(uniswapFactory.getPair(tokenIn[0], tokenOut[0]));

        (uint amount0Out, uint amount1Out) = pool.token0() == tokenIn[0] ?  (uint(0), amountIn) : (amountIn, 0);

        pool.swap(amount0Out, amount1Out, address(this), path);
    }

    // this function is called after triggering flashswap
    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external override {
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        assert(msg.sender == IUniswapV2Factory(uniswapFactory).getPair(token0, token1));

        (address[] memory tokenIn, address[] memory tokenOut) = abi.decode(data, (address[], address[]));

        uint amountIn = amount0 != 0 ? amount0 : amount1;

        for(uint i = 1; i < tokenIn.length; i++) {
            IUniswapV2Pair pool = IUniswapV2Pair(uniswapFactory.getPair(tokenIn[i], tokenOut[i]));
            (uint amount0Out, uint amount1Out) = pool.token0() == tokenIn[i] ? (amountIn, uint(0)) : (0, amountIn);
            pool.swap(amount0Out, amount1Out, address(this), new bytes(0));
            amountIn = ERC20(tokenOut[i]).balanceOf(address(this));
        }

        IUniswapV2Pair firstPool = IUniswapV2Pair(msg.sender);

        (uint reserve0, uint reserve1,) = firstPool.getReserves();

        (reserve0, reserve1) = token0 == tokenOut[0] ? (reserve0, reserve1) : (reserve1, reserve0);

        uint amountHave = IERC20(tokenIn[0]).balanceOf(address(this));
        uint amountOwed = uniswapRouter.getAmountIn(amountIn, reserve0, reserve1);
        require(amountHave > amountOwed, "Not able to return enough amount");
        IERC20(tokenIn[0]).transfer(msg.sender, amountOwed);
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
