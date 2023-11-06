//SPDX-License-Identifier: VPL

pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {IPPOMaster} from "../lvl1.sol";

interface IfVRF {
    function requestRandomWords(uint32 numWords) external returns (uint256 reqId);
    function setUp(address chance) external;
    function handleRequest(uint256 req, uint32 numWords) external;
    function handleWinRequest(uint256 req, uint32 numWords) external;
    function handleLoseRequest(uint256 req, uint32 numWords) external;
}

contract fVRF is Test{

    IPPOMaster lvl1;

    //event log_uint(uint32 num);

    function setUp(address chance) external {
        lvl1 = IPPOMaster(chance);
    }

    function requestRandomWords(
            //bytes32 keyHash,
            //uint64 s_subscriptionId,
            //uint16 requestConfirmations,
            //uint32 callbackGasLimit,
            uint32 numWords
        ) external view returns (uint256 req){
        //console.log('fvrf request');
        uint256 requestId = generateRandomNumber(numWords);
        return requestId;
    }

    function handleRequest(uint256 req, uint32 numWords , uint32 seed) external {
        uint256[] memory randomWords = new uint256[](numWords);
        for(uint32 i; i < numWords;){
            randomWords[i] = generateRandomNumber(seed-1);
            unchecked{
                ++i;
            }
        }
        fulfillRandomRequest(req,randomWords);
    }

    function fulfillRandomRequest(uint256 _requestId,uint256[] memory _randomWords) internal {
        lvl1.fulfillRandomRequest(_requestId,_randomWords);
    }

    // Function to generate a pseudo-random number
    function generateRandomNumber(uint32 i) internal view returns (uint256 randomWord) {
        //console.log('generating...');
        uint256 word = uint256(keccak256(abi.encodePacked(blockhash(block.number + 1), block.timestamp, i, msg.sender)));
        return word;// Adjust the modulus to set the desired range
    }

    //////////
    // test functions 
    /////////

    function handleLoseRequest(uint256 req, uint32 numWords) external {
        uint256[] memory losingWords = new uint256[](numWords);
        for(uint32 i; i < numWords;){
            losingWords[i] = 120;
            unchecked{
                ++i;
            }
        }
        fulfillRandomRequest(req,losingWords);
    }

    function handleWinRequest(uint256 req, uint32 numWords) external {
        uint256[] memory winningWords = new uint256[](numWords);
        for(uint32 i; i < numWords;){
            winningWords[i] = 155;
            unchecked{
                ++i;
            }
        }
        fulfillRandomRequest(req,winningWords);
    }

}