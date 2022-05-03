// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import "yield-utils-v2/contracts/token/IERC20.sol";

/**
@title A basic vault
@author Sabnock01
@notice This contract allows for deposits and withdrawals 
of an ERC20 token to a vault
*/
contract Vault {
    /// @notice the ERC20 token the vault holds
    IERC20 public token;

    /// @notice mapping from user addresses to their respective vault balance
    mapping(address => uint256) public balances;

    /// @notice  emitted when the user deposits to the vault
    event Deposited(address indexed from, uint amount);
    /// @notice emitted when the user withdraws from the vault
    event Withdrawn(address indexed to, uint amount);

    /// @param token_ the address of the ERC20 token to instantiate
    constructor(IERC20 token_) {
        token = token_;
    }

    /**
    @notice Deposits to the vault
    @param amount the amount to deposit
     */
    function deposit(uint256 amount) public {
        balances[msg.sender] += amount;
        bool successful = token.transferFrom(msg.sender, address(this), amount);
        require(successful, "Deposit failed!"); 
        emit Deposited(msg.sender, amount);
    }

    /**
    @notice Withdraws from the vault
    @param amount the amount to withdraw
     */
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] > amount, "Balance too low!");
        balances[msg.sender] -= amount;
        bool successful = token.transfer(msg.sender, amount);
        require(successful, "Withdrawal failed!");
        emit Withdrawn(msg.sender, amount);
    }
}