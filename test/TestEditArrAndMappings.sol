// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {EditArrAndMappings} from "../src/yul/EditArrAndMappings.sol";

contract TestEditArrAndMappings is Test {

    EditArrAndMappings editArrAndMappings;

    function setUp() public {
        editArrAndMappings = new EditArrAndMappings();
    }

    function testGetMappingStruct() public {
        uint key = 10;
        uint value1 = 2;
        uint value2 = 5;
        // set map 
        editArrAndMappings.setA(key, value1, value2);


        uint resValue1 = editArrAndMappings.getA(key);
        uint resValue2 = editArrAndMappings.getB(key);
        
        assertEq(value1,resValue1);
        assertEq(value2,resValue2);
    }

    function testGetMappingNested() public {
        uint key1 = 10;
        uint key2 = 2;
        uint value = 5;
        editArrAndMappings.setSuperMap(key1, key2, value);

        uint resValue = editArrAndMappings.getSuperMap(key1, key2);
        
        assertEq(value,resValue);
    }

    function testGetArr() public {
        uint256[2] memory _arr = [uint256(5), uint256(4)];
        editArrAndMappings.setArr(_arr);

        uint resValue = editArrAndMappings.getArr(1);

        assertEq(resValue,_arr[1]);
    }
}