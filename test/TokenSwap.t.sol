// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/TokenSwap.sol";
import "../src/Lazy.sol";
import {ISwapRouter} from "../src/TokenSwap.sol";

contract TokenSwapTest is Test {
    TokenSwap public tokenSwap;
    Lazy public lazyToken;
    address public uniswapRouter =
        address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // Replace with actual router address
    address public user = address(0x123);

    function setUp() public {
        lazyToken = new Lazy(1000 * 10 ** 18);
        tokenSwap = new TokenSwap(uniswapRouter, address(lazyToken));
        // Transfer tokens to the user for testing
        lazyToken.transfer(user, 100 * 10 ** 18);
    }

    function testSwapLazyForETH() public {
        uint256 amountToSwap = 50 * 10 ** 18;

        vm.startPrank(user);
        lazyToken.approve(address(tokenSwap), amountToSwap);

        // Assuming the swap happens successfully
        tokenSwap.swapLazyForETH(amountToSwap);
        vm.stopPrank();
    }

    function testSwapLazyForUSDT() public {
        uint256 amountToSwap = 50 * 10 ** 18;
        address usdtAddress = address(
            0xdAC17F958D2ee523a2206206994597C13D831ec7
        ); // Replace with actual USDT address

        vm.startPrank(user);
        lazyToken.approve(address(tokenSwap), amountToSwap);

        // Assuming the swap happens successfully
        tokenSwap.swapLazyForUSDT(amountToSwap, usdtAddress);
        vm.stopPrank();
    }
}
