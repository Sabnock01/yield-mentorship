// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import "../Registry.sol";
import "forge-std/Vm.sol";

contract RegistryTest {
    Registry public registry;
    Vm internal constant vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));

    address otherSender;

    event RegisteredName(string name, address toHolder);
    event ReleasedName(string name, address fromHolder);

    function setUp() public {
        registry = new Registry();
        otherSender = 0x0000000000000000000000000000000000000001;
    }

    function testRegisterName() public {
        vm.expectEmit(false, false, false, true);
        emit RegisteredName("Sabnock01", address(this));
        registry.register("Sabnock01");
    }

    function testReleaseName() public {
        registry.register("Sabnock01");
        vm.expectEmit(false, false, false, true);
        emit ReleasedName("Sabnock01", address(this));
        registry.release("Sabnock01");
    }

    function testRegisterHeldName() public {
        registry.register("Sabnock01");
        vm.expectRevert("Already registered!");
        vm.startPrank(otherSender);
        registry.register("Sabnock01");
        vm.stopPrank();
    }

    function testReleaseUnheldName() public {
        vm.expectRevert("You haven't registered this!");
        registry.release("alcueca");
    }
}