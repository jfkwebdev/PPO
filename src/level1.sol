//SPDX-License-Identifier: VPL

pragma solidity ^0.8.0;

import {IPPEXP1} from "./ppexp.sol";
import {IPPOMaster} from "./master.sol";

interface PPO1 {
    // function announce(address player1, uint256 character, uint256 stage, uint256 stock, uint256 reqId) external;
}

contract PPOMaster {

    address public expAdd;
    address public masterAdd;

    IPPEXP1 exp = IPPEXP1(expAdd);
    IPPOMaster master = IPPOMaster(masterAdd);

    // struct game {
    //     uint256 character;
    //     uint256 stage;
    //     uint256 stock;
    // }

    function play(uint256 character, uint256 stage, uint256 stock) public {
        master.arm(msg.sender,character,stage,stock);
    }
}
