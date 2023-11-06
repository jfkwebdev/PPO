//SPDX-License-Identifier: VPL

pragma solidity ^0.8.0;

import {IPPOMaster} from "./master.sol";
import {IfVRF} from "./fake/fakevrf.sol";
import "forge-std/Test.sol";

interface IVRF {
    function play(uint32 st) external returns (uint256 requestId);
    function fulfillRandomRequest(uint256 requestI, uint256[] memory randomWords) external;
}

contract VRF is Test {
    //VRFRouter public vrfRouter;
    IPPOMaster master;
    IfVRF vrf;

    //mapping (uint256 => bool) public games;
    //uint256[] public requests;

    constructor(address _vrfRouter, address _masterContract) {
        vrf = IfVRF(_vrfRouter);
        master = IPPOMaster(_masterContract);
    }

    function requestRandomness(uint32 numWords) internal returns (uint256 req){
        //bytes32 requestId = vrfRouter.requestRandomWords();
        //MasterContract(masterContract).handleRandomnessRequest(requestId);
        console.log("requesting randomness");
        uint256 reqId = vrf.requestRandomWords(numWords);
        // requests.push(reqId);
        return reqId;
    }

    function fulfillRandomRequest(uint256 requestI, uint256[] memory randomWords) external {
        //console.log('request fulfilled');
        uint256[] memory _words = randomWords;
        bool[10] memory _0wins;
        uint32 p0 = uint32(_words.length) / 2;
        uint32 p1 = p0;
        for(uint32 i; i < _words.length;){
            if(_words[i] % 100 < 50){
                console.log('player1 hit');
                --p0;
                //change _0wins;
            } else {
                console.log('player0 hit');
                --p1;
                _0wins[i] = true;
                //change _0wins;
            }
            if(p1 == 0 || p0 == 0){
                console.log('game over');
                break;
            }
            unchecked {
                ++i;
            }
        }
        bool vict = p0 > 0;
        master.result(requestI,vict,_0wins);
    }

    function play(
            // address player, 
            // uint32 character, 
            // uint32 stage, 
            uint32 stock
        ) external returns(uint256){
            console.log('vrf play');
            //requestRandomness(stock*2);
            uint256 game = requestRandomness(stock*2);
            //master.announce(player,character,stage,stock,game);
            return game;
        }

    error NoDice(string);
    error TooMuch(string);
    error NotEnough(string);
    error RequestFail(string);

    //important events
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    //request struct linkvrf
    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint32[] randomWords;
    }

    mapping(uint32 => RequestStatus)
    public s_requests; /* requestId --> requestStatus */

    // Your subscription ID.
    uint64 s_subscriptionId;

    // past requests Id.
    uint32[] public requestIds;
    uint32 public lastRequestId;

    // 500gwei gaslane mainnet
    bytes32 keyHash =
       0xff8dedfbfa60af186cf3c830acbc32c05aae823045ae5ea7da1e45fbfaba4f92;

    uint32 callbackGasLimit = 120000;
    uint16 requestConfirmations = 3;
    
}