// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import {ERC20} from "yield-utils-v2/contracts/token/ERC20.sol";
import {IERC20} from "yield-utils-v2/contracts/token/IERC20.sol";

/**
@title An ERC20 wrapper
@author Sabnock01
@notice You can use this contract to wrap and unwrap a specified ERC20 token
@dev The ERC20 token is set in the constructor and the wrapped tokens
are burned upon unwrapping
*/
contract ERC20Wrapper is ERC20 {
    ///@notice The ERC20 token to wrap
    IERC20 public token;

    ///@notice Event emitted when tokens are wrapped
    event Wrapped(address indexed from, uint256 amount);
    ///@notice Event emitted when tokens are unwrapped
    event Unwrapped(address indexed to, uint256 amount);

    ///@notice Creates a wrapper for a given ERC20 token
    ///@param token_ the token to wrap
    ///@param name the token's name
    ///@param symbol the token's symbol
    ///@dev the token will have 18 decimals as specified by the constructor in ERC20Mock
    constructor(IERC20 token_, string memory name, string memory symbol) ERC20(name, symbol, 18) {
        token = token_;
    }

    ///@notice Wraps tokens
    ///@param amount the amount of tokens to wrap
    ///@dev emits Wrapped event when transfer successful and error message upon failure
    function wrap(uint256 amount) public {
        _mint(msg.sender, amount);
        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "Failed to wrap tokens!"); 
        emit Wrapped(msg.sender, amount);
    }

    ///@notice Unwraps tokens
    ///@param amount the amount of tokens to unwrap
    ///@dev emits Unwrapped event when transfer successful and error message upon failure
    function unwrap(uint256 amount) public {
        _burn(msg.sender, amount);
        bool success = token.transfer(msg.sender, amount);
        require(success, "Failed to unwrap tokens!");
        emit Unwrapped(msg.sender, amount);
    }
}