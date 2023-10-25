//SPDX-License-Identifier: VPL

pragma solidity ^0.8.0;

import "forge-std/Test.sol";

interface IPPEXP1 {
    struct Team {
        uint32 first;
        uint32 second;
        uint32 third;
        uint32 fourth;
        uint32 fifth;
        uint32 sixth;
    }
    function addValue(address,uint32,uint32) external;
    function register(uint32[6] memory) external;
    function readExp(address id, uint32 char) external returns (uint32 xp);
    function readRegistrar(address id) external returns(Team memory);
}

contract PPEXP1 is Test {

/////////////////////
// State variables //
/////////////////////

    uint32 public win = 100;
    address public master;

////////////
// Events //
////////////

    event NewRegister(address player, uint32[6] team);
    event ChangeTeam(address player, uint32[6] team);
    event plusExp(address player, uint32 character, uint32 exp);

////////////   
// Errors //
////////////

    error EXP__NotFromMaster();

////////////////////////    
// Function Modifiers //
////////////////////////

modifier onlyMaster {
    if(msg.sender != master){revert EXP__NotFromMaster();}
    _;
}

/////////////////////////////
// Struct, Arrays or Enums //
/////////////////////////////

    address[] public players;
    mapping(address => Team) public registrar;
    mapping(address => mapping(uint32 => uint32)) public ranking;
    struct Team {
        uint32 first;
        uint32 second;
        uint32 third;
        uint32 fourth;
        uint32 fifth;
        uint32 sixth;
    }

/////////////////   
// Constructor //
/////////////////

constructor(address _master) {
    master = _master;
}

// Fallback — Receive function
// External visible functions

    function readExp(address id, uint32 char) external view returns(uint32 exp){
        return ranking[id][char];
    }

    function readRegistrar(address id) external view returns(Team memory){
        return registrar[id];
    }

    function register(uint32[6] memory team) external {
        players.push(msg.sender);
        Team memory newTeam = Team({
            first: team[0],
            second: team[1],
            third: team[2],
            fourth: team[3],
            fifth: team[4],
            sixth: team[5]
        });
        registrar[msg.sender] = newTeam;
        emit NewRegister(msg.sender,team);
    }

    function addValue(address player, uint32 char, uint32 stock) external onlyMaster {
        console.log('adding value');
        console.log(player);
        console.log(char);
        ranking[player][char] += win*stock;
        emit plusExp(player, char, win*stock);
    }

    function setWin(uint32 _newWin) external {
        win = _newWin;
    }

// Public visible functions
// Internal visible functions
// Private visible functions

}
