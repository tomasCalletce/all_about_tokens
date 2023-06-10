// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@solmate/tokens/ERC20.sol";

contract RewardToken is ERC20{
    
    constructor() ERC20("RE","RE",18){}

    function mint(address to,uint amount) external {
        _mint(to,amount);
    }
}

