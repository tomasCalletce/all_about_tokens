// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {GasLessToken} from "../src/GasLessToken.sol";
import {ECDSA} from "@openzeppelin/utils/cryptography/ECDSA.sol";

contract TestGasLessToken is Test {

    bytes32  constant _PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
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

    function testPermit() public {
        uint nonce = gasLessToken.nonces(publicKey);
        address owner = publicKey;
        address spender = address(this);
        uint value = 10*SCALAR;
        uint deadline = block.timestamp + 100 days;

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender,value, nonce, deadline));
        bytes32 domainSeparatorV4 = gasLessToken.domainSeparatorV4();

        bytes32 hashTypedData = ECDSA.toTypedDataHash(domainSeparatorV4, structHash);

        (uint8 v,bytes32 r,bytes32 s) = vm.sign(privateKey,hashTypedData);

        gasLessToken.permit(owner, spender, value, deadline, v, r, s);

        uint approveAmount = gasLessToken.allowance(owner, spender);

        assertEq(approveAmount,value);
    }

}
