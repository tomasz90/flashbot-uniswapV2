// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

struct PairsInfo {
    address pairAddress;
    address token0;
    address token1;
    uint24 fee;

}

contract QuickSwap is Ownable {

 UniswapV2Factory private factory = UniswapV2Factory(0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32);

    function getAllPairs(uint pageOffset, uint pageSize) public view returns (address[] memory) {
        uint lenght = getPairsLenght();
        address[] memory pairs = new address[](lenght);
        uint start = pageOffset * pageSize;
        for(uint i = start; i < start + pageSize; i++) {
            pairs[i] = factory.allPairs(i);
        }
        return pairs;
    }

    function getAllPairsInfo(uint pageOffset, uint pageSize) external view returns (PairsInfo[] memory) {
        address[] memory pairs = getAllPairs(pageOffset, pageSize);
        PairsInfo[] memory infos;
        for(uint i = 0; i < pairs.length; i++) {
            address pairAddress = pairs[i];
            UniswapPair pair = UniswapPair(pairAddress);
            infos[i] = PairsInfo(pairAddress, pair.token0(), pair.token1(), pair.fee());
        }
        return infos;
    }

    function getPairsLenght() public view returns (uint) {
        return factory.allPairsLength();
    }

    function setFactory(address newFactory) external onlyOwner {
        factory = UniswapV2Factory(newFactory);
    }

}

contract UniswapPair {
    function fee() external view returns (uint24) {}
    function token0() external view returns (address) {}
    function token1() external view returns (address) {}
}

interface UniswapV2Factory {

    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

}
