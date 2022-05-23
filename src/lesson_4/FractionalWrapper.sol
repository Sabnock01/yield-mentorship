// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import {ERC20} from "yield-utils-v2/contracts/token/ERC20.sol";
import {IERC20} from "yield-utils-v2/contracts/token/IERC20.sol";

/**
@title An Fractional ERC20 wrapper/vault
@author Sabnock01
@notice You can use this contract to wrap and unwrap a specified ERC20 token on a fractionalized basis
@dev The ERC20 token is set in the constructor and the wrapped tokens
are burned upon unwrapping
*/
contract FractionalWrapper is ERC20 {
    ///@notice The ERC20 token to wrap
    IERC20 public underlying;
    ///@notice exchange rate between asset and underlying
    ///@dev set to 27 decimal places
    uint256 public exchangeRate = 1e27;

    ///@notice Event emitted when tokens are wrapped
    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);
    ///@notice Event emitted when tokens are unwrapped
    event Withdraw(address indexed caller, address indexed receiver, address indexed owner, uint256 assets, uint256 shares);

    ///@notice Creates a fractionalized wrapper for a given ERC20 token
    ///@param token the underlying asset
    ///@param name the name of the underlying
    ///@param symbol the symbol of the underlying
    constructor(IERC20 token, string memory name, string memory symbol) ERC20(name, symbol, 18) {
        underlying = token;
    }

    ///@notice The address of the underlying token used for the vault for accounting, depositing, and withdrawing
    ///@dev Will always be an ERC20 contract
    ///@return assetTokenAddress address of the underlying token
    function asset() public view returns (address assetTokenAddress) {
        return address(underlying);
    }

    ///@notice Total amount of the underlying asset that is “managed” by the vault
    ///@return totalManagedAssets balance of the underlying token within the vault
    function totalAssets() public view returns (uint256 totalManagedAssets) {
        return underlying.balanceOf(address(this));
    }

    ///@notice Calculates the amount of the asset (wrapped) token the user can get for their amount of the underlying
    ///@param assets amount of the underlying token EX. DAI
    ///@return shares amount of the asset (wrapped) token EX. fyDAI
    function convertToShares(uint256 assets) public view returns (uint256 shares) {
        return (assets * exchangeRate) / 1e27;
    }

    ///@notice Calculates the amount of the underlying token the user can get for their shares
    ///@param shares amount of the asset (wrapped) token EX. fyDAI
    ///@return assets amount of the underlying token EX. DAI
    function convertToAssets(uint256 shares) public view returns (uint256 assets) {
        return (shares * 1e27) / exchangeRate;
    }

    ///@notice Gives the maximum amount of assets that can be deposited by the receiver
    ///@param receiver the receiving address
    ///@return maxAssets the maximum amount of assets available for deposit
    function maxDeposit(address receiver) public view returns (uint256 maxAssets) {
        return convertToAssets(_balanceOf[receiver]);
    }

    ///@notice
    ///@param assets
    ///@return shares
    function previewDeposit(uint256 assets) public view returns (uint256 shares) {
        return convertToShares(assets);
    }

    ///@notice Mints shares for the receiver based on their assets
    ///@param assets amount of the underlying asset
    ///@param receiver the receiving address 
    ///@return shares amount of the vault asset
    function deposit(uint256 assets, address receiver) public returns (uint256 shares) {
        emit Deposit(msg.sender, receiver, assets, shares);
    }

    ///@notice
    ///@param receiver
    ///@return maxShares
    function maxMint(address receiver) public view returns (uint256 maxShares) {
        return convertToShares(_balanceOf[receiver]);
    }

    ///@notice
    ///@param shares
    ///@return assets
    function previewMint(uint256 shares) public view returns (uint256 assets) {
        return convertToAssets(shares);
    }

    ///@notice 
    ///@param shares
    ///@param receiver
    ///@return assets
    function mint(uint256 shares, address receiver) public returns (uint256 assets) {
        emit Deposit(msg.sender, receiver, assets, shares);
    }

    ///@notice
    ///@param owner
    ///@return maxAssets
    function maxWithdraw(address owner) public returns (uint256 maxAssets) {
        return convertToAssets(_balanceOf[owner]);
    }

    ///@notice
    ///@param assets
    ///@return shares
    function previewWithdraw(uint256 assets) public view returns (uint256 shares) {
        return convertToShares(assets);
    }

    ///@notice 
    ///@param assets
    ///@param receiver
    ///@param owner
    ///@return shares
    function withdraw(uint256 assets, address receiver, address owner) public returns (uint256 shares) {
         emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    ///@notice
    ///@param owner
    ///@return maxShares
    function maxRedeem(address owner) public view returns (uint256 maxShares) {
        return convertToShares(_balanceOf[owner]);
    }

    ///@notice
    ///@param shares
    ///@return assets
    function previewRedeem(uint256 shares) public view returns (uint256 assets) {
        return convertToAssets(shares);
    }

    ///@notice 
    ///@param shares 
    ///@param receiver
    ///@param owner
    ///@return assets
    function redeem(uint256 shares, address receiver, address owner) public returns (uint256 assets) {
         emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }
}