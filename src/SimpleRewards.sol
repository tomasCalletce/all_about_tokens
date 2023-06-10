// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "@solmate/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";

error NoZeroDeposit();

contract SimpleRewards {
    using FixedPointMathLib for uint256;
    using SafeTransferLib for ERC20;

    struct Deposit {
        uint amount;
        uint lastBlockRewards;
        uint unclaimedRewards;
    }

    ERC20 rewardToken;

    uint public totalDeposits;
    uint public rewardPerBlock;
    uint public SCALAR;

    mapping(address => Deposit) public deposits;

    address[] public depositors;

    constructor(uint _rewardPerBlock,address _rewardToken){
        rewardPerBlock = _rewardPerBlock;
        rewardToken = ERC20(_rewardToken);
        SCALAR = 10**18;
    }

    function deposit(address depositor,uint amount) external {
       if(amount == 0) revert NoZeroDeposit();

       // update unclaimed rewards of every user because their share of the rewards is about to change
       calculateRewards();
       addStaker(depositor);

       Deposit storage depo = deposits[depositor];

       rewardToken.safeTransferFrom(msg.sender,address(this),amount);

        depo.amount = depo.amount + amount;
        depo.lastBlockRewards = block.number;
        totalDeposits = totalDeposits + amount;
    }

    function addStaker(address newDepositor) private {
        for(uint i = 0;i < depositors.length;i++){
            if(depositors[i] == newDepositor) return;
        }
        depositors.push(newDepositor);
    }

    function calculateRewards() public {
        for(uint i = 0;i < depositors.length;i++){
            Deposit storage depo = deposits[depositors[i]];
            
            // can de deposit ever be 0?
            uint blocksSinceLastReward =  block.number - depo.lastBlockRewards;
            if(blocksSinceLastReward == 0) continue;
            uint shareOfPool = depo.amount.mulDivDown(SCALAR,totalDeposits);
            uint newRewards = shareOfPool.mulDivDown(blocksSinceLastReward*rewardPerBlock,SCALAR);
            
            depo.lastBlockRewards = block.number;
            depo.unclaimedRewards = depo.unclaimedRewards + newRewards;
        }
    }
}
