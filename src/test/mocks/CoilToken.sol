// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import "yield-utils-v2/contracts/mocks/ERC20Mock.sol";

contract CoilToken is ERC20Mock {

    constructor() ERC20Mock("Coil Token", "COIL") {

    }
}