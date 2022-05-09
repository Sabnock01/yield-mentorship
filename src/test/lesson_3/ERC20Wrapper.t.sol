// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import "../../lesson_1/Registry.sol";
import {console} from "forge-std/console.sol";
import {Test} from "forge-std/Test.sol";
import {ERC20Wrapper} from "../../lesson_3/ERC20Wrapper.sol";
import {FailedTransfers} from "../../lesson_3/FailedTransfers.sol";

abstract contract ZeroState is Test{
    ERC20Wrapper public wrapper;
    FailedTransfers public token;

    event Wrapped(address indexed from, uint256 amount);
    event Unwrapped(address indexed to, uint256 amount);

    address user;

    function setUp() public virtual {
        token = new FailedTransfers();
        wrapper = new ERC20Wrapper(token, "Wrapped Coil", "WCOIL");
        user = address(1);
        vm.prank(user);
        token.approve(address(wrapper), 10 * 10**18);
        token.mint(user, 10 * 10**18);
    }
}

abstract contract WithWrappedTokens is ZeroState {
    function setUp() public override {
        super.setUp();
        vm.prank(user);
        wrapper.wrap(10 * 10**18);
    }
}

contract ERC20WrapperTest is ZeroState {
    function testWrapReverts() public {
        console.log("Wrap reverts on failure");
        token.setFailTransfers(true);
        vm.prank(user);
        vm.expectRevert("Failed to wrap tokens!");
        wrapper.wrap(1 * 10**18);
    }


    function testCannotUnwrapAmountGreaterThanWrapped() public {
        console.log("Cannot unwrap more than wrapped");
        vm.prank(user);
        vm.expectRevert("ERC20: Insufficient balance");
        wrapper.unwrap(100 * 10**18);
    }

    function testWrap() public {
        console.log("Wraps tokens successfully");
        vm.prank(user);
        vm.expectEmit(true, false, false, false);
        emit Wrapped(user, 1 * 10**18);
        wrapper.wrap(1 * 10**18);
        assertEq(wrapper.balanceOf(user), 1 * 10**18);
    }
}

contract WithWrappedTokensTest is WithWrappedTokens {
    function testUnwrapReverts() public {
        console.log("Unwrap reverts on failure");
        token.setFailTransfers(true);
        vm.prank(user);
        vm.expectRevert("Failed to unwrap tokens!");
        wrapper.unwrap(1 * 10**18);
    }

    function testUnwrap() public {
        console.log("Unwraps tokens successfully");
        vm.startPrank(user);
        vm.expectEmit(true, false, false, false);
        emit Unwrapped(user, 1 * 10**18);
        wrapper.unwrap(1 * 10**18);
        vm.stopPrank();
        assertEq(wrapper.balanceOf(user), 10 * 10**18 - 1 * 10**18);
    }
}