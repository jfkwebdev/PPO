# Power Packs Onchained Foundry 

This collection of smart contracts, tests and scripts are a workzone. It is the backbone for MiladyStation's first release: Power Packs Onchained, where digital collectibles can battle within the confines of international law.

## anvil sim setup and use

this testing environment assumes you have a metamask or web3 wallet in your browser and the PPO game site working on a local server. Please refer to this complimentary repository for instructions on how to get that rolling:

https://github.com/jfkwebdev/powerpack

This tutorial assumes you're using the default test wallet seed phrase:
test,test,test,test,test,test,test,test,test,test,test,junk


1. clone the repo 

```
git clone https://github.com/jfkwebdev/PPO
```

2. run anvil

```
anvil
```

3. In another terminal in the project directory use the forge script command to deploy the contracts

```
forge script script/Counter.s.sol:CounterScript --rpc-url $RPC_URL --broadcast  -vv
```

After following these steps, you will have a local fake blockchain that you can connect to with your web3 wallet using the custom anvil rpc: http://127.0.0.1:8545

Create a new custom network with that as the rpc.

When testing, if you change any contract code, you will need to restart anvil by terminating it with control+c on mac and running steps 2 and 3 again. You then will have to erase the history on the wallet since it will be expecting a different block number.

You will also need to change the ABI on the website and also be sure that the contract addresses are correct for the MASTER.SOL and EXP.SOL contracts that print out in the anvil console.

dm miladystation on twitter for help.

## playing

The game currently uses a pretend vrf using non random numbers. This workflow helps me avoid having to deploy onto sepolia every time I change the logic. The only draw back you have is that you have to essentially pretend to be the vrfcoordinator. Here's what play flow looks like

Assuming you have your wallet with the test rpc rolling, you will be registered with the team 171,5,4,3,2,1
the 171 pack will not work with the website as it is now. But if you play with packs 1-5 you can accrue exp.

Pick one of those packs from the character selection screen, choose anystage and click fight. This will prompt a transaction and upon confirmation the reqId will print in the console. Copy that number and use it in the following command in place of $REQ_ID:

```
cast send --private-key $VRF_ADDRESS 0x5fbdb2315678afecb367f032d93f642f64180aa3 "handleRequest(uint32,uint256)" $STOCKS $REQ_ID --from "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266" --rpc-url http://127.0.0.1:8545
```

The $VRF_ADDRESS for the test setup is 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 for me. 
The $STOCKS has to be 2 times whatever stocks you pick for the fight in order for it to match up. Usually its either 6 or 10

I keep this command in a note and edit the number and paste it into my PPO terminal to act as the vrf coordinator. While you are doing this copy and pasting, the game should stay on the matrix looking screen. Upon confirmation on the foundry anvil blockchain, the site will find the reqId and see that the game result has populated, then the fight will begin.