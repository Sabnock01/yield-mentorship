// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import "yield-utils-v2/contracts/token/IERC20.sol";
import "yield-utils-v2/contracts/mocks/ERC20Mock.sol";
import "../../lesson_2/Vault.sol";
import {console} from "forge-std/console.sol";
import {Vm} from "forge-std/Vm.sol";

abstract contract ZeroState {
    Vault public vault;
    ERC20Mock public token;
    Vm public vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    event Deposited(address indexed from, uint amount);
    event Withdrawn(address indexed to, uint amount);

    address user;

    function setUp() public virtual {
        token = new ERC20Mock("Coil Token", "COIL");
        vault = new Vault(token);
        user = address(1);
    }
}

abstract contract UserApproved is ZeroState {
    function setUp() public override virtual {
        super.setUp();
        vm.prank(user);
        token.approve(address(vault), 100 * 10**18);
    }
}

abstract contract WithBalance is UserApproved {
    function setUp() public override {
        super.setUp();
        vm.prank(user);
        token.mint(user, 10 * 10**18);
    }
}

contract VaultTest is ZeroState {
    function testCannotDepositWithoutApproval() public {
        vm.prank(user);
        vm.expectRevert("ERC20: Insufficient approval");
        vault.deposit(1 * 10**18);
    }

    function testCannotWithdrawBeforeDeposit() public {
        vm.prank(user);
        vm.expectRevert("Balance too low!");
        vault.withdraw(1 * 10**18);
    }
}

contract VaultWithBalanceTest is WithBalance {
    function testCannotWithdrawAmountGreaterThanBalance() public {
        vm.prank(user);
        vm.expectRevert("Balance too low!");
        vault.withdraw(100 * 10**18);
    }

    function testDeposit() public {
        vm.prank(user);
        vault.deposit(1 * 10**18);
    }

    function testWithdrawal() public {
        vm.startPrank(user);
        vault.deposit(5 * 10**18);
        vault.withdraw(1 * 10**18);
        vm.stopPrank();
    }
}