// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import "./CoilToken.sol";

contract FailedTransfers is CoilToken {

    bool public transferFail = false;

    function setFailTransfers(bool state) public {
        transferFail = state;
    }

    function _transfer(address src, address dst, uint wad) internal override returns (bool) {
        if (transferFail) {
            return false;
        } 
        else {
            return super._transfer(src, dst, wad);
        }
    }
} 