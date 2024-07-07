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
  mapping(address => uint256) private stakedFromTS;

    constructor(address _tokenA, address _rewardToken) {
      tokenA = IERC20(_tokenA);
      rewardToken = IERC20(_rewardToken);
  }

    function stake(uint256 amount) external {
      require(amount > 0, "amount is <= 0");
      require(balanceOf(msg.sender) >= amount, "balance is <= amount");
      _transfer(msg.sender, address(this), amount);
      if(staked[msg.sender] > 0){
        claim();
      }

      stakedFromTS[msg.sender] = block.timestamp;
      staked[msg.sender] += amount;
    }

  function claim() public {
    require(staked[msg.sender] > 0, "staked is <=0");
    uint256 secondsStaked = block.timestamp - stakedFromTs[msg.sender];
    uint256 rewards = staked[msg.sender] * secondsStaked / 3.15e7;
    transfer(???, msg.sender, amount)
    stakedFromTs[msg.sender] = block.timeStamp;
  }
}

