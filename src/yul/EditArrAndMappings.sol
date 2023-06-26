// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";

contract EditArrAndMappings {

    struct Data {
        uint128 a;
        uint128 b;
    }

    mapping(uint => Data) public map;
    mapping(uint => mapping(uint => uint)) public superMap;

     uint[] public arr;

    function getB(uint key) external view returns (uint value){
        assembly{
            mstore(0x0,key)
            let hash := keccak256(0x0,0x40)
            let val := sload(hash)
            value := and(0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff,val)
        }
    }

    function getA(uint key) external view returns (uint value){
        assembly{
            mstore(0x0,key)
            let hash := keccak256(0x0,0x40)
            let val := sload(hash)
            let valueNotShifted := and(0xffffffffffffffffffffffffffffffff00000000000000000000000000000000,val)
            value := shr(128,valueNotShifted)
        }
    }

    function setA(uint key,uint value1,uint value2) external {
        assembly{
            mstore(0x0,key)
            let hash := keccak256(0x0,0x40)
            let newValue1 := shl(128,value1)
            sstore(hash,or(newValue1,value2))
        }
    }

    function setSuperMap(uint key1,uint key2,uint value) external {
        superMap[key1][key2] = value;
    }

    function getSuperMap(uint key1,uint key2) external returns (uint value) {
        assembly{
            mstore(0x0,key1)
            mstore(0x20,superMap.slot)
            let hashOne := keccak256(0x00,0x40)
            mstore(0x0,key2)
            mstore(0x20,hashOne)
            value := sload(keccak256(0x00,0x40))
        }
    }

    function setArr(uint[2] memory _arr) external {
        arr = _arr;
    }

    function getArr(uint index) external returns (uint value){
        assembly{
            mstore(0x00,arr.slot)
            let startArr := keccak256(0x0,0x20)
            value := sload(add(index,startArr))
        }
    }
}