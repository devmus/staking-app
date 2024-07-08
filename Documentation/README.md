# Staking dApp

## Start planning (2024-07-05)

- Create a project board and break down the user stories to smaller parts.
- Research and gather information about the parts i dont know how to do.

1. Research how to create a ERC20 token.

- Search "creating an erc20 token"
- Read guide on alchemy.com (https://docs.alchemy.com/docs/how-to-create-an-erc-20-token-4-steps)

1. Create a ERC20 token.

- Create tokenA.sol file and start coding.
- Create a rewardToken.sol file and coding.

- Ask chat-GPT how \_initial_supply works with a value like `100 \* (10\*\*18)`. (Later I understand \_initial_supply is only a arbitrary constant that is used as the second argument in the \_mint function)

_Code_ I decide I want my tokenA to have a supply of 1 million and my rewardToken to have a supply of 100 million.

- Read more about ERC20 on medium (https://medium.com/@cyri113/solidity-tutorial-create-an-erc20-token-74ce94631201)

_Thoughts_ TDD is an important part of coding solidity contracts.

2. Research how to create a staking contract.

- Search "how do i create a staking contract + erc20"
- Read guides:
- - https://medium.com/@cyri113/solidity-tutorial-creating-an-erc20-staking-contract-23f34ce30b34
- - https://blog.thirdweb.com/guides/build-an-erc20-staking-smart-contract-web-application/

- Watch tutorial video:
- - Solidity Tutorial: Fixed Rate Staking Contract (https://www.youtube.com/watch?v=lQtf6mI1D70)
- - How to create an ERC20 staking app (https://www.youtube.com/watch?v=hTbYGdNFDD0)

_Thoughts_ When comparing the two videos I understand there are different ways to solving the way you create the tokens used for staking and reward. The staking contract itself can also mint the tokens needed. I consult with chat-GPT and decide to stay with the approch of creating 3 seperate contacts for the two tokens and the staking itself.

I do a Linked in learning course to get the basic understanding of solidity language a little better. (Blockchain: Learning Solidity)

I open Remix and put my token contract code in there and play around with it. I immediatly get information from the editor about my code, it is a bit out-of-date and I try to update the code to better match a modern way of writing solidity code.

I follow a guide to write the staking contract but that guide has a contract that sends reward tokens that the contract itself mints. I go to solidity docs to read about how the transfer function works so that i can instead transfer reward tokens that I have previously sent to the staking contract. At this point the docs are a bit too complex to make use of and I go to my trusted friend chatGPT to aid me.

I find out about Openzeppelin with premade contracts that can be imported and used to simplify the construction of contracts. For the token contract I already used "@openzeppelin/contracts/token/ERC20/ERC20.sol" but for the staking contract I learn about IERC20.sol SafeERC20.sol and Ownable.sol.

I manage to deploy the three contracts on remix and after that my first step is to make sure I can transfer rewardTokens to the staking contract. I also add a function in the staking contract that can display the amount of rewards token inside it. It works!

With a coding enviorment where i can do trail and error and I have taken the first few steps in this challange and made it work, I feel that I will be able to complete the challange and enjoy the journey getting there.

When trying my stake function i encounter an error in my staking contract, it checks the amount of staking tokens in the staking address itself instead of the sender address. I add a function to check the address of the sender in my staking contract and I can see it works. In the code below the msg.sender in the first function returns the correct one, but in the stake function it returns the contract address itself.

```
        function getAddressOfSender() external view returns (address) {
        return msg.sender;
    }

    function stake(uint256 amount) external {
      require(amount > 0, "amount is <= 0");
      require(tokenA.balanceOf(msg.sender) >= amount, "balance is <= amount");
      tokenA.transfer(msg.sender, amount);
      if(staked[msg.sender] > 0){
        claim();
      }

      stakedFromTS[msg.sender] = block.timestamp;
      staked[msg.sender] += amount;
    }

```

After some troubleshooting I understood that the problem was that the staking contract didn't have approval to transfer tokenA from sender. So I just had to go to tokenA contract in remix and approve the address of the staking contract to transfer funds from the wallet address i was using.

.
.
.
.
.
.
..
.

## What we want to know from you while developing the task

- Where you're identifying difficulties ?
- How and where you're searching resources for the problems you are facing ?
- Did you find any points of improvements ?
  - Write them down, explain, implement and document

This is a application which you can decide attend the objective requirements or evolve you are totally free to implement like said before your improvements

## The objective

Create a Staking Smart Contract that accepts a ERC20 token **A** which you should create. The user should be able to withdraw the token staked and withdraw another token reward which you can define the rate for. The reward token should be created by you for testing simplicity as well

### User stories

1. The user should be able to stake the token in the contract
2. The user should be able to withdraw the staked tokens from the contract
3. The user should be able to withdraw their rewards from the contract
4. The contract should be able to track users, their staked balance and how much reward they have redeemed
5. The contract should be emitting proper valuable events
6. The contract should be able to modify the reward rate by authorized access

## Optional

You can create a simple frontend using any frontend framework or pure HTML/Javascript if you know how to and even unit test, this is not considered to be evaluated nor by our team but if would like to showcase you're totally free to

## Documentation

### Topic 1

Simple example template for documenting any of the feature or improvement in the task

### Topic 2

## How do I show the results ?

You can simply invite my user `@ojoaoguilherme` to your project, tell me which commit I should look and done.
