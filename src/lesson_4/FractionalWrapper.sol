// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import {ERC20} from "yield-utils-v2/contracts/token/ERC20.sol";
import {IERC20} from "yield-utils-v2/contracts/token/IERC20.sol";
import {TransferHelper} from "yield-utils-v2/contracts/token/TransferHelper.sol";

/**
@title An Fractional ERC20 wrapper/vault
@author Sabnock01
@notice You can use this contract to wrap and unwrap a specified ERC20 token on a fractionalized basis
@dev The ERC20 token is set in the constructor and the wrapped tokens
are burned upon unwrapping
*/
contract FractionalWrapper is ERC20 {
    using TransferHelper for IERC20;
    
    ///@notice The ERC20 token to wrap
    ///@dev technically a type address to be EIP-4626 compliant but IERC20 is recognized as such by the compiler
    IERC20 public immutable asset;
    ///@notice exchange rate between asset and underlying
    ///@dev set to 26 decimal places
    uint256 public immutable exchangeRate;

    ///@notice Event emitted when tokens are wrapped
    event Deposit(
        address indexed caller, 
        address indexed owner, 
        uint256 assets, 
        uint256 shares
    );

    ///@notice Event emitted when tokens are unwrapped
    event Withdraw(
        address indexed caller, 
        address indexed receiver, 
        address indexed owner, 
        uint256 assets, 
        uint256 shares
    );

    ///@notice Creates a fractionalized wrapper for a given ERC20 token
    ///@param token the underlying asset
    ///@param name the name of the underlying
    ///@param symbol the symbol of the underlying
    constructor(IERC20 token, uint256 _exchangeRate, string memory name, string memory symbol) ERC20(name, symbol, 18) {
        asset = token;
        exchangeRate = _exchangeRate;
    }

    ///@notice Total amount of the underlying asset that is “managed” by the vault
    ///@return totalManagedAssets balance of the underlying token within the vault
    function totalAssets() public view returns (uint256 totalManagedAssets) {
        return asset.balanceOf(address(this));
    }

    ///@notice Calculates the amount of the asset (wrapped) token the user can get for their amount of the underlying
    ///@param assets amount of the underlying token EX. DAI
    ///@return shares amount of the asset (wrapped) token EX. fyDAI
    ///@dev public function for _convertToShares
    function convertToShares(uint256 assets) public view returns (uint256 shares) {
        return _convertToShares(assets);
    }

    ///@notice Calculates the amount of the asset (wrapped) token the user can get for their amount of the underlying
    ///@param assets amount of the underlying token EX. DAI
    ///@return shares amount of the asset (wrapped) token EX. fyDAI
    function _convertToShares(uint256 assets) internal view returns (uint256 shares) {
        return (assets * exchangeRate) / 1e27;
    }

    ///@notice Calculates the amount of the underlying token the user can get for their shares
    ///@param shares amount of the asset (wrapped) token EX. fyDAI
    ///@return assets amount of the underlying token EX. DAI
    ///@dev public function for _convertToAssets
    function convertToAssets(uint256 shares) public view returns (uint256 assets) {
        return _convertToAssets(shares);
    }

    ///@notice Calculates the amount of the underlying token the user can get for their shares
    ///@param shares amount of the asset (wrapped) token EX. fyDAI
    ///@return assets amount of the underlying token EX. DAI
    function _convertToAssets(uint256 shares) internal view returns (uint256 assets) {
        return (shares * 1e27) / exchangeRate;
    }

    ///@notice Gives the maximum amount of assets that can be deposited by the receiver
    ///@return maxAssets the maximum amount of assets available for deposit
    function maxDeposit(address) public pure returns (uint256 maxAssets) {
        return type(uint256).max;
    }

    ///@notice Gives the number of shares minted from a specified number of assets
    ///@param assets the number of assets
    ///@return shares the number of shares
    function previewDeposit(uint256 assets) public view returns (uint256 shares) {
        return _convertToShares(assets);
    }

    ///@notice Mints shares for the receiver based on their assets
    ///@param assets amount of the underlying asset
    ///@param receiver the receiving address 
    ///@return shares amount of the vault asset
    function deposit(uint256 assets, address receiver) public returns (uint256 shares) {
        shares = _convertToShares(assets);
        _mint(receiver, shares);
        asset.safeTransferFrom(msg.sender, address(this), assets);
        emit Deposit(msg.sender, receiver, assets, shares);
    }

    ///@notice Gives the maximum amount of shares that can be minted by the receiver
    ///@return maxShares the maximum amount of shares available for mint
    function maxMint(address) public view returns (uint256 maxShares) {
        return type(uint256).max - _totalSupply;
    }

    ///@notice Gives the number of assets minted from a specified number of shares
    ///@param shares the number of shares
    ///@return assets the number of assets
    function previewMint(uint256 shares) public view returns (uint256 assets) {
        return _convertToAssets(shares);
    }

    ///@notice Mints specified number of shares for the receiver
    ///@param shares amount of shares to be minted
    ///@param receiver the receiving address
    ///@return assets amount of the underlying asset
    function mint(uint256 shares, address receiver) public returns (uint256 assets) {
        assets = _convertToAssets(shares);
        _mint(receiver, shares);
        asset.safeTransferFrom(msg.sender, address(this), assets);
        emit Deposit(msg.sender, receiver, assets, shares);
    }

    ///@notice Gives the maximum amount of assets that can be withdrawn by the receiver
    ///@param owner the owner address
    ///@return maxAssets the maximum amount of assets available for withdrawal
    function maxWithdraw(address owner) public view returns (uint256 maxAssets) {
        return _convertToAssets(_balanceOf[owner]);
    }

    ///@notice Gives the number of shares burned from a specified number of assets
    ///@param assets the number of assets
    ///@return shares the number of shares
    function previewWithdraw(uint256 assets) public view returns (uint256 shares) {
        return _convertToShares(assets);
    }

    ///@notice Withdraws specified number of assets for the receiver
    ///@param assets the number of assets
    ///@param receiver the receiving address
    ///@param owner the owning address
    ///@return shares amount of vault asset
    function withdraw(uint256 assets, address receiver, address owner) public returns (uint256 shares) {
        shares = _convertToShares(assets);
        _burn(owner, shares);
        asset.safeTransfer(receiver, assets);
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    ///@notice Gives the maximum number of shares that can be burned by the owner
    ///@param owner the owner address
    ///@return maxShares the maximum amount of shares available for burn
    function maxRedeem(address owner) public view returns (uint256 maxShares) {
        return _balanceOf[owner];
    }

    ///@notice Gives the number of assets withdrawn from a specified number of shares
    ///@param shares the number of shares
    ///@return assets the number of assets
    function previewRedeem(uint256 shares) public view returns (uint256 assets) {
        return _convertToAssets(shares);
    }

    ///@notice Withdraws specified number of assets in terms of shares for the receiver
    ///@param shares the number of shares
    ///@param receiver the receiving address
    ///@param owner the owner address
    ///@return assets amount of the underlying asset
    function redeem(uint256 shares, address receiver, address owner) public returns (uint256 assets) {
        assets = _convertToAssets(shares);
        _burn(owner, shares);
        asset.safeTransfer(receiver, assets);
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }
}