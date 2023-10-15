//SPDX-License-Identifier: VPL

pragma solidity ^0.8.0;

import {IPPEXP1} from "./ppexp.sol";

interface IPPOMaster {
    function announce(address player1, uint256 character, uint256 stage, uint256 stock, uint256 reqId) external;
}

contract PPOMaster {
    address public expContract;
    mapping(bytes32 => address) public requestIdToSender;

    event Game(address player1, uint256 character, uint256 stage, uint256 stock, uint256 reqId);

    IPPEXP1 exp = IPPEXP1(expContract);

    function setExp(address _expContract) public {
        expContract = _expContract;
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
}
