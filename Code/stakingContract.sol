//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingContract is Ownable {
    using SafeERC20 for IERC20;

  IERC20 public tokenA;
  IERC20 public rewardToken;
  mapping(address => uint256) public staked;
  mapping(address => uint256) public rewards;
  mapping(address => uint256) public stakedFromTS;

    constructor(address _tokenA, address _rewardToken) Ownable(msg.sender) {
        tokenA = IERC20(_tokenA);
        rewardToken = IERC20(_rewardToken);
    }

    function rewardTokenBalance() external view returns (uint256) {
        return rewardToken.balanceOf(address(this));
    }

    function getAddressOfSender() external view returns (address) {
        return msg.sender;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "amount is <= 0");
        require(tokenA.balanceOf(msg.sender) >= amount, "balance is <= amount");

        updateReward(msg.sender);

        tokenA.safeTransferFrom(msg.sender, address(this), amount);

        stakedFromTS[msg.sender] = block.timestamp;
        staked[msg.sender] += amount;
    }

    function withdrawStake(uint256 amount) external {
        require(staked[msg.sender] >= amount, "Insufficient staked amount");

        updateReward(msg.sender);

        staked[msg.sender] -= amount;
        tokenA.safeTransfer(msg.sender, amount);
    }

    function updateReward(address staker) internal {
        if (staked[staker] > 0) {
            uint256 currentStakingDuration = block.timestamp - stakedFromTS[staker];
            uint256 reward = (staked[staker] * currentStakingDuration) / 100;
            rewards[staker] += reward;
            stakedFromTS[staker] = block.timestamp;
        }
    }

    function calculateReward(address staker) public view returns (uint256) {
        require(staked[staker] > 0, "No tokens staked");
        require(stakedFromTS[staker] > 0, "Staked timestamp not set");

        uint256 tempSecondsStaked = block.timestamp - stakedFromTS[staker];
        require(tempSecondsStaked > 0, "No time elapsed since staking");

        uint256 reward = (staked[staker] * tempSecondsStaked) / 100;
        return rewards[staker] + reward;
    }

    function claim() public {
        updateReward(msg.sender);
        uint256 rewardToTransfer = rewards[msg.sender];
        rewards[msg.sender] = 0;
        rewardToken.safeTransfer(msg.sender, rewardToTransfer);
    }

        function getCurrentStakingDuration(address staker) public view returns (uint256) {
        if (staked[staker] > 0) {
            return block.timestamp - stakedFromTS[staker];
        } else {
            return 0;
        }
    }
}