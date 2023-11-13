// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract SignatumToken is ERC20PresetMinterPauser, Ownable {
    using SafeMath for uint256;

    uint256 public constant totalSupplyCap = 1000000000 * 10**decimals();
    uint256 public constant dailyDistributionRate = 1000000000 - 100;

    mapping(address => uint256) public lastClaimTime;
    mapping(address => uint256) public dailyDistributionBalance;

    constructor() ERC20PresetMinterPauser("SIGNATUM", "SIGN") {
        _mint(msg.sender, 1000000000 * 10**decimals());
    }

    function claimDailyDistribution() external {
        uint256 currentTime = block.timestamp;
        uint256 elapsedTime = currentTime.sub(lastClaimTime[msg.sender]);

        // Calculate distribution based on the remaining balance in the main wallet
        uint256 distributionAmount = dailyDistributionRate.mul(elapsedTime).div(1 days);
        distributionAmount = distributionAmount.min(_balanceOfMainWallet());

        // Update distribution balances and claim time
        dailyDistributionBalance[msg.sender] = dailyDistributionBalance[msg.sender].add(distributionAmount);
        lastClaimTime[msg.sender] = currentTime;

        // Mint new tokens as distribution
        _mint(msg.sender, distributionAmount);
    }

    function _balanceOfMainWallet() internal view returns (uint256) {
        return totalSupplyCap.sub(totalSupply());
    }
}
