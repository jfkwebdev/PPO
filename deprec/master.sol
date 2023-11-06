//SPDX-License-Identifier: VPL

pragma solidity ^0.8.0;

import {IPPEXP1} from "./ppexp.sol";
import {IVRF} from "./chance.sol";
import "forge-std/Test.sol";

interface IPPOMaster {
    struct Game {
        address player0;
        uint32 char;
        uint32 stock;
        bool a;
        bool w;
        bool[10] score;
    }
    function arm(address p, uint32 c, uint32 s, uint32 st) external returns(uint256);
    function result(uint256 game, bool p0V,bool[10] memory p0ws) external;
    function setExp(address _newEXP) external;
    function setChance(address _newChance) external;
    function readSchedule(uint256 game) external view returns (Game memory);
    function readDub(uint256 game) external view returns (bool);
}

contract PPOMaster is Test{

// State variables

    address public expAdd;
    address public vrfAdd;

////////////    
// Events //
////////////

event Fight(uint256 reqId, address player1, uint32 character, uint32 stage, uint32 stock);
event newEXP(address expAdd);
event newChance(address chanceAdd);

// Function Modifiers
// Struct, Arrays or Enums

struct Game {
    address player0;
    uint32 char;
    uint32 stock;
    bool a;
    bool w;
    bool[10] score;
}

mapping (uint256 => Game) public schedule;

// Constructor
// Fallback — Receive function
// External visible functions

    function readSchedule(uint256 id) external view returns (Game memory) {
        return schedule[id];
    }

    function readDub(uint256 id) external view returns (bool) {
        return schedule[id].w;
    }

// Public visible functions
// Internal visible functions
// Private visible functions

    IPPEXP1 exp;
    IVRF chance;

    function setExp(address _newEXP) external {
        exp = IPPEXP1(_newEXP);
        emit newEXP(_newEXP);
    }
    function setChance(address _newChance) external {
        chance = IVRF(_newChance);
        emit newChance(_newChance);
    }

    function arm(address _player1, uint32 _character, uint32 _stage, uint32 _stock) external returns(uint256){
        console.log('master arm, inputs: ');
        uint256 id = chance.play(_stock);
        bool[10] memory _score; 
        console.log('sent to chance');
        console.logUint(id);
        schedule[id] = Game({
            player0: _player1, 
            char: _character, 
            stock: _stock,
            a: false,
            w: false,
            score: _score
            });
        //games.push(id);
        console.log('schedule[id] char');
        console.logUint(schedule[id].char);
        emit Fight(id, _player1,_character,_stage,_stock);
        return id;
    }

    function result(uint256 game, bool p0w, bool[10] memory p0ws) external {
        console.log('result');
        Game storage gameInstance = schedule[game];
        gameInstance.a = true;
        gameInstance.score = p0ws;
        console.log('gameInstance');
        console.log(gameInstance.player0);
        if(p0w){
            console.log('player 0 wins');
            exp.addValue(gameInstance.player0,gameInstance.char,gameInstance.stock);
            gameInstance.w = true;
        }else{
            console.log('player 1 wins');
        }
        schedule[game] = gameInstance;
    }
}