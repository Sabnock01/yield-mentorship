// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import "../../lesson_1/Registry.sol";
import {console} from "forge-std/console.sol";
import {Vm} from "forge-std/Vm.sol";

abstract contract TestCore {
    Registry public registry;
    Vm public vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address otherSender;

    event Registered(address to, string name);
    event Released(address from, string name);

    function setUp() public virtual {
        registry = new Registry();
        otherSender = 0x0000000000000000000000000000000000000001;
        vm.label(otherSender, "otherSender");
    }
}

contract UnregisteredState is TestCore {
    function testCannotReleaseUnheldName() public {
        console.log("Cannot release a name you don't already hold");
        vm.expectRevert(bytes("You haven't registered this!"));
        registry.release("alcueca");
    }


    function testCannotRegisterHeldName() public {
        console.log("Cannot register a name that is taken");
        registry.register("Sabnock01");
        vm.expectRevert(bytes("Already registered!"));
        vm.prank(otherSender);
        registry.register("Sabnock01");
    }

    function testRegisterName() public {
        console.log("Registers a name");
        vm.expectEmit(false, false, false, true);
        emit Registered(address(this), "Sabnock01");
        registry.register("Sabnock01");
    }

}

contract RegisteredState is TestCore {
    function setUp() public override {
        super.setUp();
        registry.register("Sabnock01");
    }

    function testReleaseName() public {
        console.log("Releases a name");
        vm.expectEmit(false, false, false, true);
        emit Released(address(this), "Sabnock01");
        registry.release("Sabnock01");
    }

    function testRegisterMultipleNames() public {
        console.log("Can register more than one name");
        vm.expectEmit(false, false, false, true);
        emit Registered(address(this), "alcueca");
        registry.register("alcueca");
    }
}