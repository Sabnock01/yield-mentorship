// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import {ERC20Mock} from "yield-utils-v2/contracts/mocks/ERC20Mock.sol";

/**
@title A wrapper for Ether
@author Sabnock01
@notice You can use this contract to wrap Ether
*/
contract EtherWrapper is ERC20Mock {
    ///@notice Event emitted when tokens are wrapped
    event Wrapped(address indexed from, uint256 amount);
    ///@notice Event emitted when tokens are unwrapped
    event Unwrapped(address indexed to, uint256 amount);

    ///@notice Creates a wrapper for a given ERC20 token
    ///@param name the token's name
    ///@param symbol the token's symbol
    ///@dev the token will have 18 decimals as specified by the constructor in ERC20Mock
    constructor(string memory name, string memory symbol) ERC20Mock(name, symbol) {}

    ///@notice Wraps Ether
    ///@dev emits Wrapped event when transfer successful and error message upon failure
    receive() external payable {
        _mint(msg.sender, msg.value);
        emit Wrapped(msg.sender, msg.value);  
    }

    ///@notice Unwraps Ether
    ///@param amount the amount of tokens to wrap
    ///@dev emits Unwrapped event when transfer successful and error message upon failure
    function unwrap(uint amount) public {
        _burn(msg.sender, amount);
        (bool success, )= msg.sender.call{value: amount}("");
        require(success, "Failed to unwrap tokens!");
        emit Unwrapped(msg.sender, amount);
    }

}