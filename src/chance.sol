//SPDX-License-Identifier: VPL

pragma solidity ^0.8.0;

import {IPPOMaster} from "./master.sol";

interface VRFRouter {
    function play() external returns (bytes32 requestId);
}

contract VRFInterface {
    VRFRouter public vrfRouter;
    address public masterContract;
    IPPOMaster master = IPPOMaster(masterContract);

    constructor(address _vrfRouter, address _masterContract) {
        vrfRouter = VRFRouter(_vrfRouter);
        masterContract = _masterContract;
    }

    function requestRandomness(uint256 numWords) internal returns (uint256 req){
        //bytes32 requestId = vrfRouter.requestRandomWords();
        //MasterContract(masterContract).handleRandomnessRequest(requestId);
    }

    function fulfillRandomRequest() external {

    }

    function play(
            address player, 
            uint256 character, 
            uint256 stage, 
            uint256 stock
        ) public {
            //requestRandomness(stock*2);
            master.announce(player,character,stage,stock,requestRandomness(stock*2));
        }
}