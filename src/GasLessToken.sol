// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/token/ERC20/ERC20.sol";
import "@openzeppelin/token/ERC20/extensions/ERC20Permit.sol";

contract GasLessToken is ERC20,ERC20Permit {
    
    constructor() ERC20("GL","GL") ERC20Permit("GL") {}

    function mint(address account, uint256 amount) external {
        _mint(account,amount);
    }

    function domainSeparatorV4() external returns(bytes32){
        return _domainSeparatorV4();
    }

  
    
}

