// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import "../../lesson_1/Registry.sol";
import {console} from "forge-std/console.sol";
import {Test} from "forge-std/Test.sol";
import {EtherWrapper} from "../../lesson_3/EtherWrapper.sol";

abstract contract ZeroState is Test {
    EtherWrapper public wrapper;

    event Wrapped(address indexed from, uint256 amount);
    event Unwrapped(address indexed to, uint256 amount);

    address user;

    function setUp() public virtual {
        wrapper = new EtherWrapper("Wrapped Ether", "WETH");
        user = address(1);
        vm.deal(user, 10 ether);
    }
}

abstract contract WithWrappedTokens is ZeroState {
    function setUp() public override {
        super.setUp();
        vm.prank(user);
        (bool sent,) = payable(wrapper).call{value: 5 ether}("");
        require(sent);    
    }
}

contract EtherWrapperTest is ZeroState {
    function testWrap() public {
        console.log("Wraps tokens successfully");
        vm.prank(user);
        vm.expectEmit(true, false, false, true);
        emit Wrapped(user, 1 ether);
        (bool sent,) = address(wrapper).call{value: 1 ether}("");
        require(sent);
        assertEq(wrapper.balanceOf(user), 1 ether);
        assertEq(user.balance, 9 ether);
    }
}

contract WithWrappedTokensTest is WithWrappedTokens {
    function testUnwrap() public {
        console.log("Unwraps tokens successfully");
        vm.prank(user);
        vm.expectEmit(true, false, false, true);
        emit Unwrapped(user, 1 ether);
        wrapper.unwrap(1 ether);
        assertEq(wrapper.balanceOf(user),  5 ether - 1 ether);
        assertEq(user.balance, 5 ether + 1 ether );
    }
}