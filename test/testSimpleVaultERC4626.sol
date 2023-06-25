// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {GasLessToken} from "../src/GasLessToken.sol";
import {ECDSA} from "@openzeppelin/utils/cryptography/ECDSA.sol";

contract TestGasLessToken is Test {

    uint constant SCALAR = 10**18;

    GasLessToken  gasLessToken;

    uint privateKey;
    address publicKey;

    function setUp() public {
        privateKey = 123;
        publicKey = vm.addr(privateKey);

        // contracts 
        gasLessToken = new GasLessToken();
    
        // mint rewardToken 
        gasLessToken.mint(publicKey,(type(uint).max)/2);
    }

   

}
