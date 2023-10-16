//SPDX-License-Identifier: VPL

pragma solidity ^0.8.0;

import {IPPEXP1} from "./ppexp.sol";
import {VRFRouter} from "./chance.sol";

interface IPPOMaster {
    function announce(address player1, uint256 character, uint256 stage, uint256 stock, uint256 reqId) external;
    function arm(address p, uint256 c, uint256 s, uint256 st) external;
}

contract PPOMaster {
    address public expAdd;
    address public vrfAdd;
    mapping(bytes32 => address) public requestIdToSender;

    event Game(address player1, uint256 character, uint256 stage, uint256 stock, uint256 reqId);

    IPPEXP1 exp = IPPEXP1(expAdd);
    VRFRouter vrf = VRFRouter(vrfAdd);

    function setExp(address _newEXP) public {
        expAdd = _newEXP;
    }

    function handleRandomnessRequest(bytes32 requestId) external {
        address sender = msg.sender;
        requestIdToSender[requestId] = sender;

        // Perform your logic to check randomness and decide if it's in favor
        bool isFavorable = true; // Replace with your logic

        if (isFavorable) {
            exp.addValue(sender);
        }
    }

    function announce(address _player1, uint256 _character, uint256 _stage, uint256 _stock, uint256 _reqId) public {
        emit Game(_player1,_character,_stage,_stock,_reqId);
    }

    function arm(address _player1, uint256 _character, uint256 _stage, uint256 _stock) public {
        vrf.play(_player1, _character, _stage, _stock);
    }
}
