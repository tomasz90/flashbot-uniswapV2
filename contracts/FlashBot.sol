// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol';

import './UniswapV2Library.sol';

contract FlashBot is IUniswapV2Callee, Ownable {


    function getReservesInfo(address[] memory pools) public view returns (ReserveInfo[] memory) {
        ReserveInfo[] memory infos = new ReserveInfo[](pools.length);
        for (uint256 i = 0; i < pools.length; i++) {
            IUniswapV2Pair pool = IUniswapV2Pair(pools[i]);
            (uint256 reserveAmount0, uint256 reserveAmount1, ) = pool.getReserves();

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
        (address[] memory path, address[] memory pools) = abi.decode(data, (address[], address[]));

        IUniswapV2Pair pool = IUniswapV2Pair(pools[pools.length-1]);
        
        (uint amount0Out, uint amount1Out) = pool.token0() == path[0] ? (amountIn, 0) : (uint(0), amountIn);
        pool.swap(amount0Out, amount1Out, address(this), data);
    }

    // this function is called after triggering flashswap
    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external override {
        (address[] memory path, address[] memory pools) = abi.decode(data, (address[], address[]));
        require(msg.sender == pools[pools.length-1], "sender is not a pool");

        uint amountIn = amount0 != 0 ? amount0 : amount1;
        
        // return to latest pool aka. 'linking' but in different token than borrowed
        (uint reserve0, uint reserve1) = UniswapV2Library.getReserves(pools[pools.length-1], path[0], path[1]);
        uint amountOwed = UniswapV2Library.getAmountIn(amountIn, reserve0, reserve1);

        uint[] memory amounts = UniswapV2Library.getAmountsOut(pools, amountIn, path);
        require(amounts[amounts.length-1] > amountOwed, "Not enough swap output.");

        ERC20 borrowedToken = ERC20(path[0]);
        borrowedToken.transfer(address(pools[0]), amountIn);

        multiSwap(path, pools, amounts);

        address tokenOwed = path[path.length-1];
        
        ERC20(tokenOwed).transfer(msg.sender, amountOwed);
    }

    function multiSwap(address[] memory path, address[] memory pools, uint[] memory amounts) internal {
        for(uint8 i = 0; i < pools.length-1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = UniswapV2Library.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? pools[i+1] : address(this);
            IUniswapV2Pair(pools[i]).swap(amount0Out, amount1Out, to, new bytes(0));
        }
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
