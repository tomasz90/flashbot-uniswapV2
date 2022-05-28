# Flashbot

This project shows how make flashswaps which were introduced by uniswap v2. This can be used to arbitrage the market. Bot which monitors the market when it discover uneffciency it can call ```initSwap(amountIn, data)``` to initialize arb. Data object is encoded path(ordered token addresses) + array of pools.
After first swap is done - which will be the only one flashswap - than normal swaps are performed by calling callback function by the first pool.
In the last instructions user have to give back loan.
If arbitrage is profitable transaction should pass, otherwise it will be reverted with message "Not enough swap output.".
