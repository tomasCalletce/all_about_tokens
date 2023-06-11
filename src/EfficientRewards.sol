// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "@solmate/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";

error alreadyDeposited();
error noDeposit();

contract EfficientRewards {
    using FixedPointMathLib for uint256;
    using SafeTransferLib for ERC20;

    ERC20 rewardToken;

    uint public SCALAR;

    uint public accumulatedRewardsPerShare;
    uint public lastRewardedBlock;
    uint public totalDeposits;
    uint public rewardPerBlock;

     struct Deposit {
        uint amount;
        uint inaccessibleRewards;
        address owner;
    }

    mapping(address => Deposit) public deposits;

    constructor(uint _rewardPerBlock,address _rewardToken){
        rewardPerBlock = _rewardPerBlock;
        rewardToken = ERC20(_rewardToken);
        SCALAR = 10**18;
    }

    function deposit(address newDepositor,uint amount) external {
        if(deposits[newDepositor].owner != address(0)) revert alreadyDeposited();

        updateRewards();

        rewardToken.safeTransferFrom(msg.sender,address(this),amount);

        deposits[newDepositor] = Deposit({
            amount : amount,
            inaccessibleRewards : accumulatedRewardsPerShare,
            owner : newDepositor
        });

        
        totalDeposits = totalDeposits + amount;
    }

    function withdrawRewards() external {
        updateRewards();
        Deposit storage depo = deposits[msg.sender];

        if(depo.owner != msg.sender) revert noDeposit();

        uint rewards = depo.amount.mulDivDown(accumulatedRewardsPerShare,SCALAR) - depo.inaccessibleRewards;
        depo.inaccessibleRewards = depo.inaccessibleRewards + rewards;
        
        rewardToken.safeTransfer(msg.sender,rewards);
    }

    function updateRewards() public {
        uint blocksSinceLastReward = block.number - lastRewardedBlock;
        if(blocksSinceLastReward == 0) return;

        if(totalDeposits != 0){
            uint newRewards = blocksSinceLastReward.mulDivDown(rewardPerBlock*SCALAR,totalDeposits);
            accumulatedRewardsPerShare = accumulatedRewardsPerShare + newRewards;
        }
        lastRewardedBlock = block.number;
    }

}