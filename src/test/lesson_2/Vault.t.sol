// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import "yield-utils-v2/contracts/token/IERC20.sol";
import "../../lesson_2/Vault.sol";
import "../mocks/FailedTransfers.sol";
import {console} from "forge-std/console.sol";
import {Vm} from "forge-std/Vm.sol";
import "forge-std/Test.sol";

abstract contract ZeroState is Test {
    Vault public vault;
    FailedTransfers public token;
    // Vm public vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    event Deposited(address indexed from, uint amount);
    event Withdrawn(address indexed to, uint amount);

    address user;

    function setUp() public virtual {
        token = new FailedTransfers();
        vault = new Vault(token);
        user = address(1);
        vm.startPrank(user);
        token.approve(address(vault), 100 * 10**18);
        token.mint(user, 10 * 10**18);
        vm.stopPrank();
    }
}

abstract contract WithBalance is ZeroState {
    function setUp() public override {
        super.setUp();
        vm.prank(user);
        vault.deposit(5 * 10**18);
    }
}

contract VaultTest is ZeroState {
    function testDepositRevertsOnFailedTransfer() public {
        console.log("Deposit reverts on failed transfer");
        token.setFailTransfers(true);
        vm.startPrank(user);
        vm.expectRevert("Deposit failed!");
        vault.deposit(1 * 10**18);
        vm.stopPrank();
    }

    function testCannotWithdrawAmountGreaterThanBalance() public {
        console.log("Cannot withdraw more than deposited");
        vm.prank(user);
        vm.expectRevert("Balance too low!");
        vault.withdraw(100 * 10**18);
    }

    function testDeposit() public {
        console.log("Deposits successfully");
        vm.prank(user);
        vm.expectEmit(true, false, false, false);
        emit Deposited(user, 1 * 10**18);
        vault.deposit(1 * 10**18);
        assertEq(vault.balances(user), 1 * 10**18);
    }
}

contract VaultWithBalanceTest is WithBalance {
    function testWithdrawRevertsIfTransferFails() public {
        console.log("Withdraw reverts on failed withdrawal");
        token.setFailTransfers(true);
        vm.prank(user);
        vm.expectRevert("Withdrawal failed!");
        vault.withdraw(1 * 10**18);
    }

    function testWithdrawal() public {
        console.log("Withdraws successfully");
        vm.startPrank(user);
        vm.expectEmit(true, false, false, false);
        emit Withdrawn(user, 1**18);
        vault.withdraw(1 * 10**18);
        vm.stopPrank();
        assertEq(vault.balances(user), 5 * 10**18 - 1 * 10**18);
    }
}