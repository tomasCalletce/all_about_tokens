// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {GasLessToken} from "../src/GasLessToken.sol";
import {ECDSA} from "@openzeppelin/utils/cryptography/ECDSA.sol";
import {MathRounding} from "../src/MathRounding.sol";

contract TestGasLessToken is Test {

    enum Direction {
        token0_TO_token1,
        token1_TO_token0
    }

    uint constant SCALAR = 10**6;

    GasLessToken  token0;
    GasLessToken  token1;

    MathRounding bank;

    function setUp() public {
        // tokens  
        token0 = new GasLessToken();
        token1 = new GasLessToken();

        // make bank 
        bank = new MathRounding(address(token0),address(token1));
    
        // mint 0 token 
        token0.mint(address(this),(type(uint).max)/2);
        token0.mint(address(bank),(type(uint).max)/2);

        // mint 1 token 
        token1.mint(address(this),(type(uint).max)/2);
        token1.mint(address(bank),(type(uint).max)/2);

        // approve 
        token0.approve(address(bank),type(uint).max);
        token1.approve(address(bank),type(uint).max);
    }

    // function testInAndOutToken0() public {
    //     uint amountIn = 76003000327;

    //     uint outAmount0 = bank.swap(amountIn,0);
    //     uint outAmount1 = bank.swap(outAmount0,1);

      
    //    assertEq(outAmount1,amountIn);
    // }

    // function testInAndOutToken1() public  {
    //     uint amountIn = 357280507182357;

    //     uint outAmount0 = bank.swap(amountIn,1);
    //     uint outAmount1 = bank.swap(outAmount0,0);

        
    //    assertEq(outAmount1,amountIn);
    // }

    function testRoundingDepoRedeem() public {
        uint startingBalance = 3;

        uint shares = bank.deposti(startingBalance);
        uint assets = bank.redeem(shares);
    }

    // function testFuzz_Rounding(uint startingShares) public {
    //     vm.assume(startingShares <= type(uint).max/2);
    //     uint assets = bank.mint(startingShares);
    //     uint endShares = bank.withdraw(assets);

    //     assert(startingShares >= endShares);
    // }
   

}
