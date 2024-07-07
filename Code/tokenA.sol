//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenA is ERC20 {
    uint constant INITIAL_SUPPLY = 1000000 * (10**18);

    constructor() ERC20("tokenA", "TA") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}

