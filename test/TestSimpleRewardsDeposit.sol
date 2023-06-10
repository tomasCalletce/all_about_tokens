// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {ERC20} from  "@solmate/tokens/ERC20.sol";
import {RewardToken} from "../src/RewardToken.sol";
import {SimpleRewards} from "../src/SimpleRewards.sol";
import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";

contract TestSimpleRewardsDeposit is Test {
    using FixedPointMathLib for uint256;

    SimpleRewards public simpleRewards;
    RewardToken public rewardToken;

    uint constant SCALAR = 10**18;
    uint constant rewardPerBlock = 1*SCALAR;

    function setUp() public {
        // contracts 
        rewardToken = new RewardToken();
        simpleRewards = new SimpleRewards(1*SCALAR,address(rewardToken));

        // mint rewardToken 
        rewardToken.mint(address(this),type(uint).max);

        // approve rewardToken
        rewardToken.approve(address(simpleRewards),type(uint).max);

    }

    function testCorrectDeposit() public {
        uint depositAmount = 10*SCALAR;
        simpleRewards.deposit(address(this),depositAmount);

        (uint amount,
        uint lastBlockRewards,
        uint unclaimedRewards) = simpleRewards.deposits(address(this));

        assertEq(amount,depositAmount);
        assertEq(lastBlockRewards,block.number);
        assertEq(simpleRewards.depositors(0),address(this));
    }

    function testCalculateRewardsWithOneUser() public {
        uint depositAmount = 10*SCALAR;
        simpleRewards.deposit(address(this),depositAmount);

        uint currentBlock = block.number;
        uint blocksPassed = 100;
        vm.roll(currentBlock+blocksPassed);

        simpleRewards.calculateRewards();

        (uint amount,
        uint lastBlockRewards,
        uint unclaimedRewards) = simpleRewards.deposits(address(this));

        uint rewardPerBlock = simpleRewards.rewardPerBlock();
        uint shareOfPool = 1*SCALAR;
        uint newRewards = shareOfPool.mulDivDown(blocksPassed*rewardPerBlock,SCALAR);

        assertEq(newRewards,unclaimedRewards);
    }

    function testChangeExistingDepositorsRewardsAfterDeposit() public {
        address user1 = address(this);
        address user2 = 0xa4Bea5B05449652c1A267e90B20ebac9F8eECA6a;

        uint depositAmount = 10*SCALAR;
        simpleRewards.deposit(user1,depositAmount);

        uint currentBlock = block.number;
        uint blocksPassed = 100;
        vm.roll(currentBlock+blocksPassed);

        simpleRewards.deposit(user2,depositAmount);

        (uint amountUser1,
        uint lastBlockRewardsUser1,
        uint unclaimedRewardsUser1) = simpleRewards.deposits(user1);

        (uint amountUser2,
        uint lastBlockRewardsUser2,
        uint unclaimedRewardsUser2) = simpleRewards.deposits(user2);

        assertEq(amountUser1,depositAmount);
        assertEq(amountUser2,depositAmount);

        uint totalAmount = simpleRewards.totalDeposits();
        assertEq(totalAmount,depositAmount*2);

        uint rewardPerBlock = simpleRewards.rewardPerBlock();
        uint shareOfPool = 1*SCALAR;
        uint newRewards = shareOfPool.mulDivDown(blocksPassed*rewardPerBlock,SCALAR);

        assertEq(newRewards,unclaimedRewardsUser1);
    }


    function testChangeInRewardsMultipleUsers() public {
        address user1 = address(this);
        address user2 = 0xa4Bea5B05449652c1A267e90B20ebac9F8eECA6a;
        uint blocksPassed = 100;
        uint depositAmount = 10*SCALAR;

        simpleRewards.deposit(user1,depositAmount);
        vm.roll(block.number+blocksPassed);
        simpleRewards.deposit(user2,depositAmount);
        vm.roll(block.number+blocksPassed);
        simpleRewards.calculateRewards();

        (,,uint unclaimedRewardsUser1) = simpleRewards.deposits(user1);

        (,,uint unclaimedRewardsUser2) = simpleRewards.deposits(user2);

        uint rewardPerBlock = simpleRewards.rewardPerBlock();
        uint shareOfPoolTime100 = 1*SCALAR;
        uint shareOfPoolTime50 = shareOfPoolTime100/2;

        uint newRewardsUser1 = shareOfPoolTime100.mulDivDown(blocksPassed*rewardPerBlock,SCALAR) + shareOfPoolTime50.mulDivDown(blocksPassed*rewardPerBlock,SCALAR);
        uint newRewardsUser2 = shareOfPoolTime50.mulDivDown(blocksPassed*rewardPerBlock,SCALAR);

        assertEq(newRewardsUser1,unclaimedRewardsUser1);
        assertEq(newRewardsUser2,unclaimedRewardsUser2);
    }


}
