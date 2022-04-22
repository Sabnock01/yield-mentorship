// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

/**
@title A name registry
@author Sabnock01
@notice You can use this contract to register and release names. A name once
registered cannot be claimed by another until released. 
*/
contract Registry {
    // mapping from names to holders
    mapping (string => address) holder;

    event RegisteredName(string name, address toHolder);
    event ReleasedName(string name, address fromHolder);

    /**
    @notice Registers a name
    @param name The name to register
     */
    function register(string calldata name) public {
        require(nameToHolder[name] == address(0), "Already registered!");
        nameToHolder[name] = msg.sender;
        emit RegisteredName(name, msg.sender);
    }

    /**
    @notice Releases a name
    @param name The name to release
     */
    function release(string calldata name) public {
        require(nameToHolder[name] == msg.sender, "You haven't registered this!");
        nameToHolder[name] = address(0);
        emit ReleasedName(name, msg.sender);
    }
}