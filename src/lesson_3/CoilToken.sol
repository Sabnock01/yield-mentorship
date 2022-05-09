// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import {ERC20Mock} from "yield-utils-v2/contracts/mocks/ERC20Mock.sol";

/**
@title An ERC20 token
@author Sabnock01
@notice You can use this contract to wrap and unwrap a specified ERC20 token
*/

contract CoilToken is ERC20Mock {

    constructor() ERC20Mock("Coil Token", "COIL") {

    }
} 