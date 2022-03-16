// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract QuickSwap {

 UniswapV2Factory private quickswap = UniswapV2Factory(0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32);

    function getAllPairs(uint pageOffset, uint pageSize) external view returns (address[] memory) {
        uint lenght = getPairsLenght();
        address[] memory pairs = new address[](lenght);
        uint start = pageOffset * pageSize;
        for(uint i = start; i < start + pageSize; i++) {
            pairs[i] = quickswap.allPairs(i);
        }
        return pairs;
    }

    function getPairsLenght() public view returns (uint) {
        return quickswap.allPairsLength();
    } 

}

contract Tokens {
    address wmatic = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address sand = 0xBbba073C31bF03b8ACf7c28EF0738DeCF3695683;
    address wbtc = 0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6;
    address weth = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address usdc = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address mimatic = 0xa3Fa99A148fA48D14Ed51d610c367C61876997F1;
    address cxeth = 0xfe4546feFe124F30788c4Cc1BB9AA6907A7987F9;
    address cxada = 0x64875Aaa68d1d5521666C67d692Ee0B926b08b2F;
    address usdt = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
    address qi = 0x580A84C73811E1839F75d86d75d88cCa0c241fF4;
    address cxdoge = 0x9Bd9aD490dD3a52f096D229af4483b94D63BE618;
    address dai = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
    address gns = 0xE5417Af564e4bFDA1c483642db72007871397896;
    address ageur = 0xE0B52e49357Fd4DAf2c15e02058DCE6BC0057db4;
    address ixt = 0xE06Bd4F5aAc8D0aA337D13eC88dB6defC6eAEefE;
    address ice = 0xc6C855AD634dCDAd23e64DA71Ba85b8C51E5aD7c;
    address quick = 0x831753DD7087CaC61aB5644b308642cc1c33Dc13;
    address ghst = 0x385Eeac5cB85A38A9a07A70c73e0a3271CfB54A7;
    address aave = 0xD6DF932A45C0f255f85145f286eA0b292B21C90B;
    address link = 0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39;
    address tel = 0xdF7837DE1F2Fa4631D716CF2502f8b230F1dcc32;
    address milk = 0x1599fE55Cda767b1F631ee7D414b41F5d6dE393d;
    address ust = 0xE6469Ba6D2fD6130788E0eA9C0a0515900563b59;
    address luna = 0x9cd6746665D9557e1B9a775819625711d0693439;
    address cubo = 0x381d168DE3991c7413d46e3459b48A5221E3dfE4;
    address dlycop = 0x1659fFb2d40DfB1671Ac226A0D9Dcc95A774521A;
    address usdtw = 0x9417669fBF23357D2774e9D421307bd5eA1006d2;
    address busd = 0xA8D394fE7380b8cE6145d5f85E6aC22d4E91ACDe;
    address rise = 0x0cD022ddE27169b20895e0e2B2B8A33B25e63579;
    address wbnb = 0xeCDCB5B88F8e3C15f95c720C51c71c9E2080525d;
    address blok = 0x229b1b6C23ff8953D663C4cBB519717e323a0a84;
    address cel = 0xD85d1e945766Fea5Eda9103F918Bd915FbCa63E6;
    address xzar = 0x30DE46509Dbc3a491128F97be0aAf70dc7Ff33cB;
    address chp = 0x59B5654a17Ac44F3068b3882F298881433bB07Ef;
    address mocean = 0x282d8efCe846A88B159800bd4130ad77443Fa1A1;
    address gogo = 0xdD2AF2E723547088D3846841fbDcC6A8093313d6;
    address sol = 0xd93f7E271cB87c23AaA73edC008A79646d1F9912;
    address mana = 0xA1c57f48F0Deb89f569dFbE6E2B7f46D33606fD4;
    address zinu = 0x21F9B5b2626603e3F40bfc13d01AfB8c431D382F;
    address combo = 0x6DdB31002abC64e1479Fc439692F7eA061e78165;
    address mooned = 0x7E4c577ca35913af564ee2a24d882a4946Ec492B;
    address flame = 0x22e3f02f86Bc8eA0D73718A2AE8851854e62adc5;
    address ftm = 0xB85517b87BF64942adf3A0B9E4c71E4Bc5Caa4e5;
}

interface UniswapV2Factory {

    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

}
