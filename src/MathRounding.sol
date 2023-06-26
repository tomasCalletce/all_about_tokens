// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@solmate/tokens/ERC20.sol";

contract MathRounding  {
    using SafeMath for uint256;

    uint constant token0Totoken1Rate = 4700873724;
    uint constant assetsPerShare = 2;
    uint constant SCALAR = 10**6;
    
    ERC20 token0;
    ERC20 token1;

    mapping(address => uint) public balanceOf;

    constructor(address _token0,address _token1){
        token0 = ERC20(_token0);
        token1 = ERC20(_token1);
    }


    function deposti(uint assets) external returns(uint){
        uint shares = assets.div(assetsPerShare);
        //token0.transferFrom(msg.sender,address(this), assets);
        balanceOf[msg.sender] += shares;
        return shares;
    }

    function mint(uint shares) external returns(uint){
        uint assets = shares*assetsPerShare;
        //token0.transferFrom(msg.sender,address(this), assets);
        balanceOf[msg.sender] += shares;
        return assets; 
    }

    function redeem(uint shares) external returns(uint){
        uint assets = shares.mul(assetsPerShare);
        balanceOf[msg.sender] -= shares;
        //token0.transfer(msg.sender, assets);
        return assets;
    }

    function withdraw(uint assets) external returns(uint){
        uint shares = assets/assetsPerShare;
        balanceOf[msg.sender] -= shares;
        //token0.transfer(msg.sender, assets);
        return shares;
    }

    function swap(uint amount,uint direction) external returns(uint amountOut){
        if(direction == 0){
            amountOut = (amount*token0Totoken1Rate)/SCALAR;

            token0.transferFrom(msg.sender,address(this), amount);
            token1.transfer(msg.sender,amountOut);
        }else{
            amountOut = (amount*SCALAR)/token0Totoken1Rate;

            token1.transferFrom(msg.sender,address(this), amount);
            token0.transfer(msg.sender,amountOut);
        }
    }
}


library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 quotient = a / b;
        uint256 remainder = a % b;

        if (remainder >= b / 2) {
            quotient++;
        }
        return quotient;
    }
}

