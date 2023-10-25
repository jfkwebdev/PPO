//SPDX-License-Identifier: VPL

pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {IVRF} from "../chance.sol";

interface IfVRF {
    function requestRandomWords(uint32 numWords) external returns (uint256 reqId);
    function setUp(address chance) external;
    function handleRequest(uint32 numWords, uint256 req) external;
}

contract fVRF is Test{

    event ChanceSet();
    
    uint32 seed = 10;

    uint256[] public requestIds;

    IVRF vrf;

    //event log_uint(uint32 num);

    function setUp(address chance) external {
        vrf = IVRF(chance);
        //console.log(vrf);
        emit ChanceSet();
    }

    function setRandomness(uint32 newSeed) external {
        seed = newSeed;
    }

    function requestRandomWords(
        uint32 numWords
        ) external returns (uint256 req){
        console.log('fvrf request r');
        uint256 requestId = generateRandomNumber(888);
        requestIds.push(requestId);
        //handleRequest(numWords,requestId);
        return requestId;
    }

    function handleRequest(uint32 numWords, uint256 req) external {
        //simulateFiveMinuteDelay();
        //console.log('numWords');
        //console.logUint(numWords);
        console.log('we are pretending to be chainlink router here');
        uint256[] memory randomWords = new uint256[](numWords);
        for(uint32 i; i < numWords;){
            randomWords[i] = generateRandomNumber(seed-i);
            unchecked{
                ++i;
            }
        }
        //console.log('after loop in handle request');
        fulfillRandomRequest(req,randomWords);
    }

    function fulfillRandomRequest(uint256 _requestId,uint256[] memory _randomWords) internal {
        //console.log('before sending to chance');
        vrf.fulfillRandomRequest(_requestId,_randomWords);
        //console.log('after sending to chance');
    }

    // Function to generate a pseudo-random number
    function generateRandomNumber(uint32 i) internal view returns (uint256 randomWord) {
        console.log('generating...');
        uint256 word = uint256(keccak256(abi.encodePacked(blockhash(block.number + 1), block.timestamp, i, msg.sender)));
        //console.log('seed is good');
        //console.logUint(seed);
        return word;// Adjust the modulus to set the desired range
    }

    function simulateFiveMinuteDelay() public {
        uint256 fiveMinutesInSeconds = 5 * 60;  // 5 minutes in seconds
        uint256 currentTimestamp = block.timestamp;
        uint256 targetTimestamp = currentTimestamp + fiveMinutesInSeconds;
        //emit log_uint(block.timestamp);
        // Use the vm.warp function to fast-forward to the target time
        vm.warp(targetTimestamp);
        // Emit the current timestamp after the delay
        //emit log_uint(block.timestamp);
    }

}