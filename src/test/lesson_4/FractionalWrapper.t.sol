// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import {console} from "forge-std/console.sol";
import {Test} from "forge-std/Test.sol";
import {FractionalWrapper} from "../../lesson_4/FractionalWrapper.sol";
import {FailedTransfers} from "../mocks/FailedTransfers.sol";

abstract contract ZeroState is Test {
    FractionalWrapper public wrapper;
    FailedTransfers public token;

    event Deposit(
        address indexed caller, 
        address indexed owner, 
        uint256 assets, 
        uint256 shares
    );

    event Withdraw(
        address indexed caller, 
        address indexed receiver, 
        address indexed owner, 
        uint256 assets, 
        uint256 shares
    );

    address user;

    function setUp() public virtual {
        token = new FailedTransfers();
        wrapper = new FractionalWrapper(token, 20 * (10**26), "Wrapped Coil", "WCOIL");
        user = address(1);
        vm.prank(user);
        token.mint(user, 10**18);
    }
}

abstract contract WithTokens is ZeroState {
    function setUp() public override {
        super.setUp();
        vm.startPrank(user);
        token.approve(address(wrapper), 10**18);
        wrapper.deposit(10**18, user);
        vm.stopPrank();
    }
}

contract FractionalWrapperTest is ZeroState {
    function testCorrectAsset() public {
        console.log("Contains the correct asset as underlying");
        assertEq(address(token), address(wrapper.asset()));
    }

    function testCorrectExchangeRate() public {
        console.log("Has correct exchange rate");
        assertEq(wrapper.exchangeRate(), 20 * (10**26));
    }

    function testTotalAssets() public {
        console.log("Returns correct amount of total assets");
        assertEq(wrapper.totalAssets(), 0);
    }

    function testConvertToShares() public {
        console.log("Converts the amounts of assets successfully");
        assertEq(wrapper.convertToShares(1), 2);
        assertEq(wrapper.convertToShares(2), 4);
        assertEq(wrapper.convertToShares(7), 14);
        assertEq(wrapper.convertToShares(10), 20);
        assertEq(wrapper.convertToShares(100), 200);
    }

    function testConvertToAssets() public {
        console.log("Converts the amounts of shares successfully");
        assertEq(wrapper.convertToAssets(1), 0);
        assertEq(wrapper.convertToAssets(10), 5);
        assertEq(wrapper.convertToAssets(70), 35);
        assertEq(wrapper.convertToAssets(100), 50);
        assertEq(wrapper.convertToAssets(200), 100);
    }

    function testMaxDeposit(address receiver) public {
        console.log("Retrieves max deposit amount successfully");
        assertEq(wrapper.maxDeposit(receiver), type(uint256).max);
    }

    function testPreviewDeposit(uint256 assets) public {
        console.log("Gives correct amount of shares");
        vm.assume(assets <= 1e27);
        assertEq(wrapper.previewDeposit(assets), wrapper.convertToShares(assets));
    }

    function testDeposit(address receiver) public {
        console.log("Deposits tokens successfully");
        vm.startPrank(user);
        token.approve(address(wrapper), 10);
        vm.expectEmit(true, true, true, true);
        emit Deposit(
            user,
            receiver, 
            10, 
            wrapper.convertToShares(10)
        );
        uint256 shares = wrapper.deposit(10, receiver);
        vm.stopPrank();
        assertEq(shares, wrapper.convertToShares(10));
        assertEq(wrapper.balanceOf(receiver), wrapper.convertToShares(10));
        assertEq(token.balanceOf(user), 10**18 - 10);
    }

    function testMaxMint(address receiver) public {
        console.log("Retrieves max mint amount successfully");
        console.log(wrapper.totalSupply());
        assertEq(wrapper.maxDeposit(receiver), type(uint256).max);
    }

    function testPreviewMint(uint256 shares) public {
        console.log("Gives correct number of assets");
        vm.assume(shares <= 1e27);
        assertEq(wrapper.previewMint(shares), wrapper.convertToAssets(shares));
    }

    function testMint(address receiver)  public {shares
        console.log("Mints tokens successfully");
        vm.startPrank(user);
        token.approve(address(wrapper), 10);
        vm.expectEmit(true, true, true, true);
        emit Deposit(
            user,
            receiver,
            10,
            wrapper.convertToShares(10)
        );
        uint256 assets = wrapper.mint(wrapper.convertToShares(10), receiver);
        vm.stopPrank();
        assertEq(assets, 10);
        assertEq(wrapper.balanceOf(receiver), wrapper.convertToShares(10));
        assertEq(token.balanceOf(user), 10**18 - 10);
    }

    function testPreviewWithdraw(uint256 assets) public {
        console.log("Gives correct number of shares");
        vm.assume(assets <= 1e27);
        assertEq(wrapper.previewWithdraw(assets), wrapper.convertToShares(assets));
    }

    function testPreviewRedeem(uint256 shares) public {
        console.log("Gives correct number of assets");
        vm.assume(shares <= 1e27);
        assertEq(wrapper.previewRedeem(shares), wrapper.convertToAssets(shares));
    }
}

contract WithTokensTest is WithTokens {
    function testMaxWithdraw() public {
        console.log("Retrieves max withdraw amount successfully");
        assertEq(wrapper.maxWithdraw(address(0)), 0);
        assertEq(wrapper.maxWithdraw(user), 10**18);  
    }

    function testMaxRedeem() public {
        console.log("Retrieves max redeem amount successfully");
        assertEq(wrapper.maxRedeem(address(0)), 0);
        assertEq(wrapper.maxRedeem(user), 10**18 * 2);
    }

    function testWithdraw() public {
        console.log("Withdraws tokens successfully");
        address receiver = address(2);
        address caller = address(3);

        vm.prank(user);
        wrapper.approve(caller, 10);
        vm.expectEmit(true, true, true, true);
        emit Withdraw(
            caller,
            receiver,
            user,
            10,
            wrapper.convertToShares(10)
        );
        vm.prank(caller);
        uint256 shares = wrapper.withdraw(10, receiver, user);
        assertEq(shares, wrapper.convertToShares(10));
        assertEq(wrapper.balanceOf(user), wrapper.convertToShares(10**18 - 10));
        assertEq(wrapper.balanceOf(caller), 0);
        assertEq(wrapper.balanceOf(receiver), 0);
        assertEq(token.balanceOf(receiver), 10);
    }

    function testRedeem() public {
        console.log("Redeems tokens successfully");
        address receiver = address(2);
        address caller = address(3);

        vm.prank(user);
        wrapper.approve(caller, 10);
        vm.expectEmit(true, true, true, true);
        emit Withdraw(
            caller,
            receiver,
            user,
            wrapper.convertToAssets(10), 
            10
        );
        vm.prank(caller);
        uint256 assets = wrapper.redeem(10, receiver, user);
        assertEq(assets, wrapper.convertToAssets(10));
        assertEq(wrapper.balanceOf(user), wrapper.convertToShares(10**18) - 10);
        assertEq(wrapper.balanceOf(caller), 0);
        assertEq(wrapper.balanceOf(receiver), 0);
        assertEq(token.balanceOf(receiver), wrapper.convertToAssets(10));
    }
}
