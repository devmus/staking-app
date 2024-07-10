//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingContract is Ownable {
    using SafeERC20 for IERC20;

  IERC20 private tokenA;
  IERC20 private rewardToken;
  uint256 private rewardRate;

  mapping(address => uint256) private staked;
  mapping(address => uint256) public rewards;
  mapping(address => uint256) private stakedFromTS;

  struct StakedUser{
    address user;
    uint256 amount;
    uint256 rewardsClaimed;
  }

  StakedUser[] private stakedUsers;
  mapping(address => uint256) private userIndex;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 reward);
    event RewardRateUpdated(uint256 oldRewardRate, uint256 newRewardRate);

    constructor(address _tokenA, address _rewardToken, uint256 _initialRewardRate) Ownable(msg.sender) {
        tokenA = IERC20(_tokenA);
        rewardToken = IERC20(_rewardToken);
        rewardRate = _initialRewardRate;
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

        if (staked[msg.sender] == 0) {
            stakedUsers.push(StakedUser(msg.sender, amount, 0));
            userIndex[msg.sender] = stakedUsers.length - 1;
        } else {
            updateReward(msg.sender);
            stakedUsers[userIndex[msg.sender]].amount += amount;
        }

        tokenA.safeTransferFrom(msg.sender, address(this), amount);

        stakedFromTS[msg.sender] = block.timestamp;
        staked[msg.sender] += amount;

        emit Staked(msg.sender, amount);
    }

    function withdrawStake(uint256 amount) external {
        require(staked[msg.sender] >= amount, "Insufficient staked amount");

        updateReward(msg.sender);

        staked[msg.sender] -= amount;
        stakedUsers[userIndex[msg.sender]].amount -= amount;
        tokenA.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);

        // if (staked[msg.sender] == 0) {
        //     removeStakedUser(msg.sender);
        // }
    }

    function getStakedUsers() external view returns (StakedUser[] memory) {
        return stakedUsers;
    }

    // function removeStakedUser(address user) internal {
    //     uint256 index = userIndex[user];
    //     uint256 length = stakedUsers.length;

    //      if (index < length - 1) {
    //         stakedUsers[index] = stakedUsers[length - 1];
    //         userIndex[stakedUsers[index].user] = index;
    //     }

    //     stakedUsers.pop();
    //     delete userIndex[user];
    // }

    function updateReward(address staker) internal {
        if (staked[staker] > 0) {
            uint256 currentStakingDuration = block.timestamp - stakedFromTS[staker];
            uint256 reward = (staked[staker] * currentStakingDuration) / rewardRate;
            rewards[staker] += reward;
            stakedFromTS[staker] = block.timestamp;
        }
    }

    function calculateReward() public view returns (uint256) {
        require(staked[msg.sender] > 0, "No tokens staked");
        require(stakedFromTS[msg.sender] > 0, "Staked timestamp not set");

        uint256 tempSecondsStaked = block.timestamp - stakedFromTS[msg.sender];
        require(tempSecondsStaked > 0, "No time elapsed since staking");

        uint256 reward = (staked[msg.sender] * tempSecondsStaked) / rewardRate;

        return rewards[msg.sender] + reward;
    }

    function claim() public {
        updateReward(msg.sender);

        uint256 rewardToTransfer = rewards[msg.sender];
        rewards[msg.sender] = 0;

        stakedUsers[userIndex[msg.sender]].rewardsClaimed  += rewardToTransfer;

        rewardToken.safeTransfer(msg.sender, rewardToTransfer);

        emit Claimed(msg.sender, rewardToTransfer);
    }

    function getCurrentStakingDuration() public view returns (uint256) {
        if (staked[msg.sender] > 0) {
            return block.timestamp - stakedFromTS[msg.sender];
        } else {
            return 0;
        }
    }

    function setRewardRate(uint256 newRewardRate) external onlyOwner {
        
        for (uint256 i = 0; i < stakedUsers.length; i++) {
            updateReward(stakedUsers[i].user);
        }
        
        emit RewardRateUpdated(rewardRate, newRewardRate);
        rewardRate = newRewardRate;
    }
}