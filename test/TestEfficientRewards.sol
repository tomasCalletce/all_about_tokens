// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {ERC20} from  "@solmate/tokens/ERC20.sol";
import {RewardToken} from "../src/RewardToken.sol";
import {EfficientRewards} from "../src/EfficientRewards.sol";
import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";

contract TestEfficientRewards is Test {
    using FixedPointMathLib for uint256;


    EfficientRewards public efficientRewards;
    RewardToken public rewardToken;

    uint constant SCALAR = 10**18;
    uint constant rewardPerBlock = 1*SCALAR;

    function setUp() public {
        // contracts 
        rewardToken = new RewardToken();
        efficientRewards = new EfficientRewards(1*SCALAR,address(rewardToken));

        // mint rewardToken 
        rewardToken.mint(address(this),(type(uint).max)/2);

        // approve rewardToken
        rewardToken.approve(address(efficientRewards),type(uint).max);

        // send tokens to give as rewards 
        rewardToken.mint(address(efficientRewards),(type(uint).max)/2);
    }

    function testCorrectDeposit() public {
        address depositor = address(this);
        uint depositAmount = 10*SCALAR;

        efficientRewards.deposit(depositor,depositAmount);

        (uint amount,
        uint inaccessibleRewards,
        address owner) = efficientRewards.deposits(depositor);


        uint totalDeposits = efficientRewards.totalDeposits();
        uint accumulatedRewardsPerShare = efficientRewards.accumulatedRewardsPerShare();
        uint lastRewardedBlock = efficientRewards.lastRewardedBlock();

        assertEq(totalDeposits,depositAmount);
        assertEq(lastRewardedBlock,block.number);
        assertEq(accumulatedRewardsPerShare,0);
    }

    function testCalculateRewardsWithOneUser() public {
        address depositor = address(this);
        uint depositAmount = 10*SCALAR;
        uint currentBlock = block.number;
        uint blocksPassed = 100;

        efficientRewards.deposit(depositor,depositAmount);

        vm.roll(currentBlock+blocksPassed);

        efficientRewards.updateRewards();

        uint totalDeposits = efficientRewards.totalDeposits();
        uint accumulatedRewardsPerShare = efficientRewards.accumulatedRewardsPerShare();
        uint lastRewardedBlock = efficientRewards.lastRewardedBlock();

        assertEq(accumulatedRewardsPerShare,rewardPerBlock.mulDivDown(blocksPassed*SCALAR,totalDeposits));
        assertEq(lastRewardedBlock,blocksPassed+currentBlock);
    }

    function testRewardsWithdraw() public {
        address depositor = address(this);
        uint depositAmount = 10*SCALAR;
        uint currentBlock = block.number;
        uint blocksPassed = 100;

        efficientRewards.deposit(depositor,depositAmount);

        vm.roll(currentBlock+blocksPassed);

        efficientRewards.updateRewards();

        uint userBalanceBefore = rewardToken.balanceOf(depositor);
        efficientRewards.withdrawRewards();
        uint userBalanceAfter = rewardToken.balanceOf(depositor);

        uint withdrawRewards = userBalanceAfter - userBalanceBefore;

        (uint amount,
        uint inaccessibleRewards,
        address owner) = efficientRewards.deposits(depositor);

        uint accumulatedRewardsPerShare = efficientRewards.accumulatedRewardsPerShare();

        assertEq(withdrawRewards,accumulatedRewardsPerShare.mulDivDown(depositAmount,SCALAR));
        assertEq(inaccessibleRewards,withdrawRewards);
    }
}