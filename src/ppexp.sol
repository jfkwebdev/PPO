//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "solady/auth/Ownable.sol";

interface IPPEXP1 {
    function addValue(address,uint32,uint32) external;
    function obliviate(address,uint32) external;
    function register(uint32[6] memory) external;
    function knight(uint32 char, string memory title) external;
    function incorporate(string memory userName) external;
    function readPackExp(address id, uint32 char) external returns (uint32 xp);
    function readRoster(address id, uint32 char) external returns (string memory);
    function readStats(uint32 char) external view returns (uint256 atk, uint256 def, uint256 spd);
    function readPlayers() external view returns (address[] memory) ;
    function readRegistrar(address id) external returns(uint32[6] memory);
    function readCanon(address id) external returns(string memory);
}

contract PPEXP1 is Ownable {

/////////////////////
// State variables //
/////////////////////

    uint32 public win = 100;
    IPPEXP1 public old;

////////////
// Events //
////////////

    event NewRegister(address player, uint32[6] team);
    event NewUser(address player, string name);
    event ChangeTeam(address player, uint32[6] team);
    event plusExp(address player, uint32 character, uint32 exp);
    event Knighted(address player, uint32 character, string title);
    event Legalized(address executor);
    event ChangeWin(uint32 newWin);
    event Obliviated(address player, uint32 character);

////////////   
// Errors //
////////////

    error EXP__NotFromMaster();
    error EXP__LowLevel();
    error EXP__WinOverFlow();
    error EXP__UnauthorizedFight();
    error EXP__DuplicateTeam();

////////////////////////    
// Function Modifiers //
////////////////////////

modifier onlyLegal {
    if(!legal[msg.sender]){revert EXP__UnauthorizedFight();}
    _;
}


/////////////////////////////
// Struct, Arrays or Enums //
/////////////////////////////

    address[] public players;
    mapping(address => string) public canon;
    mapping(address => uint32[6]) public registrar;
    mapping(address => mapping(uint32 => uint32)) public ranking;
    mapping(address => mapping(uint32 => string)) public roster;
    mapping(address => bool) public legal;

/////////////////   
// Constructor //
/////////////////

    constructor() {
        _initializeOwner(msg.sender);
    }

////////////////////////////////
// External visible functions //
////////////////////////////////

    function readPlayers() external view returns (address[] memory) {
        return players;
    }
    function readPackExp(address id, uint32 char) external view returns(uint32 exp){
        return ranking[id][char];
    }

    function readRegistrar(address id) external view returns(uint32[6] memory){
        return registrar[id];
    }

    function readRoster(address player, uint32 char) external view returns(string memory){
        return roster[player][char];
    }

    function readCanon(address player) external view returns(string memory){
        return canon[player];
    }

    function readStats(uint32 char) external pure returns (uint256 atk, uint256 def, uint256 spd) {
        uint256 _atk = uint256(keccak256(abi.encodePacked(char)));
        uint256 _def = uint256(keccak256(abi.encodePacked(1e18/char)));
        uint256 _spd = uint256(keccak256(abi.encodePacked(char*char)));
        return (_atk % 1000,_def % 1000,_spd % 1000);
    }

    function addValue(address player, uint32 char, uint32 stock) external onlyLegal {
        ranking[player][char] += win*stock;
        emit plusExp(player, char, win*stock);
    }

    function obliviate(address player, uint32 char) external onlyLegal {
        ranking[player][char] = 0;
        emit Obliviated(player,char);
    }

    function bless(address player, uint32 char, uint32 exp) external onlyLegal {
        ranking[player][char] = exp;
        emit plusExp(player,char,exp);
    }

    function incorporate(string memory userName) external {
        //Level12
        if(userExp(msg.sender) < 1728){revert EXP__LowLevel();}
        canon[msg.sender] = userName;
        emit NewUser(msg.sender,userName);
    }

    function knight(uint32 char, string memory title) external {
        //PPLevel30
        if(ranking[msg.sender][char] < 27000){revert EXP__LowLevel();}
        roster[msg.sender][char] = title;
        emit Knighted(msg.sender,char,title);
    }

    function setWin(uint32 _newWin) external onlyOwner {
        if(_newWin >= 10000){revert EXP__WinOverFlow();}
        win = _newWin;
        emit ChangeWin(_newWin);
    }

    function legalize(address newArena) external onlyOwner {
        legal[newArena] = !legal[newArena];
        emit Legalized(newArena);
    }

    function register(uint32[6] memory team) external {
        for(uint8 i; i<5;){
            for(uint8 j=i+1; j<6;){
                if(team[i]==team[j]){
                    revert EXP__DuplicateTeam();
                }
                unchecked{
                    ++j;
                }
            }
            unchecked{
                ++i;
            }
        }
        players.push(msg.sender);
        registrar[msg.sender] = team;
        emit NewRegister(msg.sender,team);
    }

    function upgrade(address oldExp) external onlyOwner {
        IPPEXP1 _oldExp = IPPEXP1(oldExp);
        address[] memory oldPlayers = _oldExp.readPlayers();
        uint32[6] memory oldTeam;
        for(uint256 i = 0; i < oldPlayers.length;){
            players.push(oldPlayers[i]);
            oldTeam = _oldExp.readRegistrar(oldPlayers[i]);
            registrar[oldPlayers[i]] = oldTeam;
            for(uint8 p = 0; p < 6;){
                ranking[oldPlayers[i]][oldTeam[p]] = _oldExp.readPackExp(oldPlayers[i],oldTeam[p]);
                unchecked {
                    ++p;
                }
            }
            emit NewRegister(oldPlayers[i], oldTeam);
            unchecked {
                ++i;
            }
        }
    }


//////////////
// Internal //
//////////////


    function userExp(address player) internal view returns(uint32){
        uint32 xp;
        uint32[6] memory _team = registrar[player];
        for(uint8 i; i < 6;){
            xp += ranking[player][_team[i]];
            unchecked {
                ++i;
            }
        }
        return xp;
    }


}
