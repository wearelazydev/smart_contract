// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Lazy.sol";

contract LazyTest is Test {
    Lazy public lazyToken;
    address public user;

    function setUp() public {
        // Deploy Lazy contract with an initial supply of 1000 tokens
        lazyToken = new Lazy(1000 * 10 ** 18);
        user = address(0x123);
    }

    function testInitialSupply() public {
        uint256 initialSupply = lazyToken.totalSupply();
        assertEq(
            initialSupply,
            1000 * 10 ** 18,
            "Initial supply should be correct"
        );
    }

    function testMinting() public {
        uint256 balance = lazyToken.balanceOf(address(this));
        assertEq(
            balance,
            1000 * 10 ** 18,
            "Balance should be the initial supply minted to the sender"
        );
    }

    function testTransfer() public {
        lazyToken.transfer(user, 100 * 10 ** 18);
        uint256 userBalance = lazyToken.balanceOf(user);
        assertEq(
            userBalance,
            100 * 10 ** 18,
            "User should receive the correct amount of tokens"
        );
    }
}
