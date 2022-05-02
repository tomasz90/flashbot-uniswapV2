// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

abstract contract SwapV2Callee {

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external {
        executeCall(sender, amount0, amount1, data);
    }

    function pancakeCall(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external {
        executeCall(sender, amount0, amount1, data);
    }

    function elkCall(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external {
        executeCall(sender, amount0, amount1, data);
    }

    function pangolinCall(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external {
        executeCall(sender, amount0, amount1, data);
    }

    function joeCall(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external {
        executeCall(sender, amount0, amount1, data);
    }

    function executeCall(address sender, uint amount0, uint amount1, bytes calldata data) internal virtual;
}