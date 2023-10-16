//SPDX-License-Identifier: VPL

pragma solidity ^0.8.0;

interface IPPEXP1 {
    function addValue(address) external;
    function addPlayer(address) external;
}

contract PPEXP1 {
    address[] public players;
    mapping(address => uint256) public rolo;
    uint256 public win;

    function setWin(uint256 _newWin) external {
        win = _newWin;
    }

    function addValue(address id) external {
        rolo[id] += win;
    }

    function addPlayer(address id) external {
        players.push(id);
    }

    function readExp(address id) external view returns(uint256 exp){
        return rolo[id];
    }

}
