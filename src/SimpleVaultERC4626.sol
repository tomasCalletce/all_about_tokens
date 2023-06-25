// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {ERC20} from "@solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "@solmate/utils/SafeTransferLib.sol";

contract SimpleVaultERC4626 is ERC20 {
    using SafeTransferLib for ERC20;

    event Deposit(
        address indexed caller,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    event Withdraw(
        address indexed caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    ERC20 public immutable asset;

    constructor(
        ERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol, _asset.decimals()) {
        asset = _asset;
    }

    function deposit(uint256 assets, address receiver) external returns (uint256) {
        uint256 shares = previewDeposit(assets);
        require(shares != 0, "ZERO_SHARES");

        asset.safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);
        return shares;
    }

    function mint(uint256 shares, address receiver) external returns (uint256) {
        uint256 assets = previewMint(shares);
        asset.safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);
        return shares;
    }

    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) external returns (uint256) {
        uint256 shares = previewWithdraw(assets);
        if (msg.sender != owner) {
        allowance[owner][msg.sender] -= shares;
        }

        _burn(owner, shares);
        asset.safeTransfer(receiver, assets);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);
        return shares;
    }

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) external returns (uint256) {
        if (msg.sender != owner) {
        allowance[owner][msg.sender] -= shares;
        }

        uint256 assets = previewRedeem(shares);
        require(assets != 0, "ZERO_ASSETS");

        _burn(owner, shares);
        asset.safeTransfer(receiver, assets);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);
        return assets;
    }

    function totalAssets() public view returns (uint256) {
        return asset.balanceOf(address(this));
    }

    function maxDeposit(address) external view returns (uint256) {
        return type(uint256).max;
    }

    function maxMint(address) external view returns (uint256) {
        return type(uint256).max;
    }

    function maxWithdraw(address owner) external view returns (uint256) {
        return convertToAssets(balanceOf[owner]);
    }

    function maxRedeem(address owner) external view returns (uint256) {
        return balanceOf[owner];
    }

    function convertToShares(uint256 assets) public view returns (uint256) {
        if (totalSupply == 0) {
        return assets;
        }

        return (assets * totalSupply) / totalAssets();
    }

    function convertToAssets(uint256 shares) public view returns (uint256) {
        if (totalSupply == 0) {
        return shares;
        }

        return (shares * totalAssets()) / totalSupply;
    }

    function previewDeposit(uint256 assets) public view returns (uint256) {
        return convertToShares(assets);
    }

    function previewMint(uint256 shares) public view returns (uint256) {
        return convertToAssets(shares);
    }

    function previewWithdraw(uint256 assets) public view returns (uint256) {
        return convertToShares(assets);
    }

    function previewRedeem(uint256 shares) public view returns (uint256) {
        return convertToAssets(shares);
    }
}