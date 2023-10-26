# Power Packs Onchained Foundry 

This collection of smart contracts, tests and scripts are a workzone. It is the backbone for MiladyStation's first release: Power Packs Onchained, where digital collectibles can battle within the confines of international law.

## anvil sim setup and use

this testing environment assumes you have a metamask or web3 wallet in your browser and the PPO game site working on a local server. Please refer to this complimentary repository for instructions on how to get that rolling:

https://github.com/jfkwebdev/packbrawl

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