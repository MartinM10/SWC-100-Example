// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {LotterySystem} from "../src/Lottery.sol";

contract LotterySystemTest is Test {
    LotterySystem lottery;
    address owner;
    address user1;
    address user2;
    address user3;
    address attacker;

    function setUp() public {
        lottery = new LotterySystem();

        owner = address(this); // Asignamos una dirección válida como propietario

        // Create 3 user addresses and 1 attacker address
        user1 = vm.addr(20);
        user2 = vm.addr(30);
        user3 = vm.addr(40);
        attacker = vm.addr(50);

        // Fund user addresses with ether
        vm.deal(owner, 10 ether);
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.deal(user3, 10 ether);
        vm.deal(attacker, 10 ether); // Attacker has some initial funds to start transactions
    }

    modifier onlyOwner() {
        vm.startPrank(owner);
        _;
        vm.stopPrank();
    }

    function testMultiUserTicketPurchase() public {
        lottery.startLottery(1 ether);

        // User1 buys a ticket
        vm.startPrank(user1);
        lottery.buyTicket{value: 1 ether}(1);
        vm.stopPrank();

        // User2 buys a ticket
        vm.startPrank(user2);
        lottery.buyTicket{value: 1 ether}(1);
        vm.stopPrank();

        // User3 buys a ticket
        vm.startPrank(user3);
        lottery.buyTicket{value: 1 ether}(1);
        vm.stopPrank();

        (, , uint256 prizePool, ) = lottery.getLotteryInfo(1);
        assertEq(
            prizePool,
            3 ether,
            "Prize pool should be 3 ether after three tickets purchased"
        );
        console.log(
            "Multi-user ticket purchase simulated successfully, prize pool:",
            prizePool
        );

        // Check contract balance
        uint256 contractBalance = lottery.getContractBalance();
        assertEq(
            contractBalance,
            3 ether,
            "Contract balance should be 3 ether after ticket purchases"
        );
        console.log("Contract balance is correct:", contractBalance);
    }

    function testMultiUserLotteryEnd() public {
        lottery.startLottery(1 ether);

        // Users buy tickets
        vm.startPrank(user1);
        lottery.buyTicket{value: 1 ether}(1);
        vm.stopPrank();

        vm.startPrank(user2);
        lottery.buyTicket{value: 1 ether}(1);
        vm.stopPrank();

        vm.startPrank(user3);
        lottery.buyTicket{value: 1 ether}(1);
        vm.stopPrank();

        // Skip forward in time to simulate end of lottery
        vm.warp(block.timestamp + 15 minutes);

        // End the lottery
        lottery.endLottery(1);

        (, , uint256 prizePool, bool isActive) = lottery.getLotteryInfo(1);

        assertFalse(isActive, "Lottery should be inactive after ending");
        assertEq(prizePool, 0, "Prize pool should be reset to 0 after ending");
        console.log("Multi-user lottery end simulated successfully");
    }

    function testMultiUserOneTicketPerAccount() public {
        lottery.startLottery(1 ether);

        // User1 buys a ticket
        vm.startPrank(user1);
        lottery.buyTicket{value: 1 ether}(1);

        vm.expectRevert("Only one ticket per account allowed");
        lottery.buyTicket{value: 1 ether}(1);
        vm.stopPrank();
        console.log(
            "Verified only one ticket per account restriction for user1"
        );

        // User2 buys a ticket
        vm.startPrank(user2);
        lottery.buyTicket{value: 1 ether}(1);

        vm.expectRevert("Only one ticket per account allowed");
        lottery.buyTicket{value: 1 ether}(1);
        vm.stopPrank();
        console.log(
            "Verified only one ticket per account restriction for user2"
        );

        // User3 buys a ticket
        vm.startPrank(user3);
        lottery.buyTicket{value: 1 ether}(1);

        vm.expectRevert("Only one ticket per account allowed");
        lottery.buyTicket{value: 1 ether}(1);
        vm.stopPrank();
        console.log(
            "Verified only one ticket per account restriction for user3"
        );
    }

    function testContractVulnerability() public {
        lottery.startLottery(1 ether);

        // Users buy tickets
        vm.startPrank(user1);
        lottery.buyTicket{value: 1 ether}(1);
        vm.stopPrank();

        vm.startPrank(user2);
        lottery.buyTicket{value: 1 ether}(1);
        vm.stopPrank();

        vm.startPrank(user3);
        lottery.buyTicket{value: 1 ether}(1);
        vm.stopPrank();

        // Attacker attempts to exploit the vulnerability
        vm.startPrank(attacker);
        uint256 initialAttackerBalance = attacker.balance;
        lottery._sendPrize(payable(attacker), 3 ether);
        vm.stopPrank();

        uint256 finalAttackerBalance = attacker.balance;
        assertEq(
            finalAttackerBalance,
            initialAttackerBalance + 3 ether,
            "Attacker should be able to steal the prize pool"
        );
        console.log(
            "Vulnerability test passed: Attacker was able to exploit the public _sendPrize function"
        );
    }

    function testStartLotteryRevertIfNotOwner() public {
        vm.prank(user1);
        vm.expectRevert("Only owner can call this function");
        console.log(
            "Calling startLottery function with a non-owner address..."
        );
        lottery.startLottery(1 ether);
    }

    function testBuyTicketRevertIfLotteryNotActive() public {
        lottery.startLottery(1 ether);
        vm.prank(owner);
        lottery.cancelLottery(1);
        vm.prank(user1);
        vm.expectRevert("Lottery is not active");
        console.log("Calling buyTicket function when lottery is not active...");
        lottery.buyTicket{value: 1 ether}(1);
    }

    function testBuyTicketRevertIfAlreadyBought() public {
        lottery.startLottery(1 ether);
        vm.prank(user1);
        lottery.buyTicket{value: 1 ether}(1);
        vm.prank(user1);
        vm.expectRevert("Only one ticket per account allowed");
        console.log(
            "Calling buyTicket function when ticket has already been bought..."
        );
        lottery.buyTicket{value: 1 ether}(1);
    }

    function testBuyTicketRevertIfIncorrectPrice() public {
        lottery.startLottery(1 ether);
        vm.prank(user1);
        vm.expectRevert("Incorrect ticket price");
        console.log(
            "Calling buyTicket function with incorrect ticket price..."
        );
        lottery.buyTicket{value: 0.5 ether}(1);
    }

    function testEndLotteryRevertIfNotOwner() public {
        lottery.startLottery(1 ether);
        vm.prank(user1);
        lottery.buyTicket{value: 1 ether}(1);
        vm.warp(block.timestamp + 15 minutes);
        vm.prank(user1);
        vm.expectRevert("Only owner can call this function");
        console.log("Calling endLottery function with a non-owner address...");
        lottery.endLottery(1);
    }

    function testEndLotteryRevertIfNotActive() public {
        lottery.startLottery(1 ether);
        vm.prank(user1);
        lottery.buyTicket{value: 1 ether}(1);
        vm.warp(block.timestamp + 15 minutes);
        vm.prank(owner);
        lottery.endLottery(1);
        vm.prank(owner);
        vm.expectRevert("Lottery is not active");
        console.log(
            "Calling endLottery function when lottery is not active..."
        );
        lottery.endLottery(1);
    }

    function testEndLotteryRevertIfEnded() public {
        lottery.startLottery(1 ether);
        vm.prank(user1);
        lottery.buyTicket{value: 1 ether}(1);
        vm.prank(owner);
        vm.warp(block.timestamp + 15 minutes);
        lottery.endLottery(1);
        vm.expectRevert("Lottery is not active");
        console.log(
            "Calling endLottery function when lottery is still active..."
        );
        lottery.endLottery(1);
    }

    function testEndLotteryRevertIfNoPlayers() public {
        lottery.startLottery(1 ether);
        vm.warp(block.timestamp + 15 minutes);
        vm.prank(owner);
        vm.expectRevert("No players in the lottery");
        console.log("Calling endLottery function when there are no players...");
        lottery.endLottery(1);
    }

    function testCancelLotteryRevertIfPlayersExist() public {
        lottery.startLottery(1 ether);
        vm.prank(user1);
        lottery.buyTicket{value: 1 ether}(1);
        vm.prank(owner);
        vm.expectRevert("Cannot cancel lottery with players");
        console.log("Calling cancelLottery function when players exist...");
        lottery.cancelLottery(1);
    }

    function testCancelLotteryRevertIfNotOwner() public {
        lottery.startLottery(1 ether);
        vm.prank(owner);
        lottery.cancelLottery(1);
        vm.prank(user1);
        vm.expectRevert("Only owner can call this function");
        console.log(
            "Calling cancelLottery function with a non-owner address..."
        );
        lottery.cancelLottery(1);
    }
}
