//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IPPEXP1} from "./ppexp.sol";
import "chainlink/shared/access/ConfirmedOwner.sol";
import "chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import "chainlink/vrf/VRFConsumerBaseV2.sol";

interface IPPOMaster {
    struct Game {
        address player0;
        uint32 char;
        uint32 stock;
        bool a;
        bool w;
        bool[10] score;
        uint256 wager;
    }
    function sponsor(address p, uint32 c, uint32 s, uint32 st, uint256 wager) external returns(uint256);
    function claim() external;
    function readBusiness() external view returns (bool);
    function readTote() external view returns (bool);
    function readFee() external view returns (uint256);
    function readSchedule(uint256 game) external view returns (Game memory);
    function readDub(uint256 game) external view returns (bool);
    function readBook(address player) external view returns (uint256);
    function readWinnings(address player) external view returns (uint256);
    function readLosses(address player) external view returns (uint256);
    function readActivity() external view returns (uint256);
    function readMaxBet() external view returns(uint256);
}

contract PPOMaster is VRFConsumerBaseV2, ConfirmedOwner {

    error NoDice(string);
    error lvl1__InsufficientFee();
    error lvl1__NotOpen();
    error lvl1__ToteClosed();
    error lvl1__TooMuchSize();
    error lvl1__InsufficientCredit();
    error lvl1__SaturatedCredit();
    error lvl1__StockOverflow();
    error lvl1__CurrentlyEngaged();
    error lvl1__notCool();
    
// State variables

    IPPEXP1 exp;
    bool public open;
    bool public safe;
    uint64 s_subscriptionId;
    //arb goerli 0x83d1b6e3388bed3d76426974512bb0d270e9542a765cd667242ea26c0cc0b730
    //arb 2gwei 0x08ba8f62ff6c40a58877a106147661db43bc58dabfb814793847a839aa03367f
    bytes32 keyHash = 0x83d1b6e3388bed3d76426974512bb0d270e9542a765cd667242ea26c0cc0b730;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint256 public games;
    uint256 public fee = 40000000000000;
    uint256 public health = 500; // 500 = 5%

////////////    
// Events //
////////////

event Fight(uint256 reqId, address player1, uint32 character, uint32 stage, uint32 stock, uint256 wager);
event newEXP(address expAdd);
event newFee(uint256 newFee);
event newChance(address chanceAdd);
event RequestFulfilled(uint256 requestId, uint256[] randomWords);
event Loaded(uint256 value);
event HouseWins(uint256 winning);

////////////////////////
// Function Modifiers //
////////////////////////

modifier overhead(uint256 credit) {
    uint256 _fee = fee;
    uint256 _health = checkHealth();
    uint256 _account = book[msg.sender];
    if(block.timestamp < coolDown[msg.sender]){revert lvl1__notCool();}
    if(msg.value < _fee){revert lvl1__InsufficientFee();}
    if(!safe && (msg.value > fee || credit > 0)){revert lvl1__ToteClosed();}
    if(credit > _account){revert lvl1__InsufficientCredit();}
    if((credit + msg.value - _fee) > _health){revert lvl1__TooMuchSize();}  
    if(_account + credit + msg.value - _fee > _health*4){revert lvl1__SaturatedCredit();}
    if(msg.value > _fee){
        purchaseCredit(msg.value - _fee);
    }
    book[owner()] += _fee;
    _;
}

modifier business() {
    if(!open){revert lvl1__NotOpen();}
    _;
}

/////////////////////////////
// Struct, Arrays or Enums //
/////////////////////////////

struct Game {
    address player0;
    uint32 char;
    uint32 stock;
    bool a;
    bool w;
    bool[10] score;
    uint256 wager;
}

mapping(address => uint256) public coolDown;
mapping(address => bool) public engagement;
mapping(address => uint256) public losses;
mapping(address => uint256) public winnings;
mapping(address => uint256) public book;
mapping (uint256 => Game) public schedule;
VRFCoordinatorV2Interface COORDINATOR;

/////////////////
// Constructor //
/////////////////

    constructor ( uint64 subscriptionId) 
    ConfirmedOwner(msg.sender)
    //arb 0x41034678D6C633D8a95c75e1138A360a28bA15d1
    //arb goerli 0x6D80646bEAdd07cE68cab36c27c626790bBcf17f
    VRFConsumerBaseV2(0x6D80646bEAdd07cE68cab36c27c626790bBcf17f)
    {
        COORDINATOR = VRFCoordinatorV2Interface(
            0x6D80646bEAdd07cE68cab36c27c626790bBcf17f
        );
        s_subscriptionId = subscriptionId;
    }

////////////////////////////////
// External visible functions //
////////////////////////////////

    function readBusiness() external view returns (bool) {
        return open;
    }

    function readTote() external view returns (bool) {
        return safe;
    }

    function readFee() external view returns (uint256) {
        return fee;
    }

    function readWinnings(address player) external view returns (uint256) {
        return winnings[player];
    }

    function readLosses(address player) external view returns (uint256) {
        return losses[player];
    }

    function readBook(address player) external view returns (uint256) {
        return book[player];
    }

    function readSchedule(uint256 id) external view returns (Game memory) {
        return schedule[id];
    }

    function readDub(uint256 id) external view returns (bool) {
        return schedule[id].w;
    }

    function readActivity() external view returns (uint256) {
        return games;
    }

    function readMaxBet() external view returns(uint256){
        return checkHealth();
    }

    function sponsor(
            address _player1, 
            uint32 _character, 
            uint32 _stage, 
            uint32 _stock, 
            uint256 _wager
        ) external payable 
            overhead(_wager) 
            business() 
        returns(uint256){
            if(_stock > 5){revert lvl1__StockOverflow();}
            engagement[msg.sender] = true;
            uint256 id = COORDINATOR.requestRandomWords(
                keyHash,
                s_subscriptionId,
                requestConfirmations,
                callbackGasLimit,
                _stock*2);
            bool[10] memory _score; 
            schedule[id] = Game({
                player0: _player1, 
                char: _character, 
                stock: _stock,
                a: false,
                w: false,
                score: _score,
                wager: msg.value + _wager - fee
            });
            coolDown[msg.sender] = block.timestamp + _stock*15;
            ++games;
            emit Fight(id, _player1,_character,_stage,_stock, _wager);
            return id;
    }

    function setExp(address _newEXP) external onlyOwner {
        exp = IPPEXP1(_newEXP);
        emit newEXP(_newEXP);
    }

    function setFee(uint256 _newFee) external onlyOwner {
        fee = _newFee;
        emit newFee(_newFee);
    }

    function configure(uint32 newGasLimit, bytes32 newGasLane, uint256 newHealth, uint16 newConfirmations) external onlyOwner {
        if(newGasLimit != 0){
            callbackGasLimit = newGasLimit;
        }
        keyHash = newGasLane;
        if(newHealth != 0) {
            health = newHealth;
        }
        if(newConfirmations != 0){
            requestConfirmations = newConfirmations;
        }
    }

    function ignition() external onlyOwner {
        open = !open;
    }

    function nitro() external onlyOwner {
        safe = !safe;
    }

    function adminWithdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
        open = false;
    }

    function claim() external business() {
        if(engagement[msg.sender]){revert lvl1__CurrentlyEngaged();}
        payable(msg.sender).transfer(book[msg.sender]);
        winnings[msg.sender] += book[msg.sender];
        book[msg.sender] = 0;
    }

    function load() external payable {
        emit Loaded(msg.value);
    }

    function deem() external onlyOwner {
        engagement[msg.sender] = false;
    }

    ////////////////////////
    // Internal Functions //
    ////////////////////////

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        if(schedule[requestId].player0 == address(0)){revert NoDice("game not found");}
        emit RequestFulfilled(requestId, randomWords);
        uint256[] memory _words = randomWords;
        bool[10] memory _0wins;
        uint32 p0 = uint32(_words.length) / 2;
        uint32 p1 = p0;
        for(uint32 i; i < _words.length;){
            if(_words[i] % 1000 < 500)
            { --p0;} else {--p1;
                _0wins[i] = true;
            }
            if(p1 == 0 || p0 == 0){
                break;
            }
            unchecked {
                ++i;
            }
        }
        //bool vict = ;
        result(requestId,p0 > 0,_0wins);
    }

    function result(uint256 game, bool p0w, bool[10] memory p0ws) internal {
        Game memory gameInstance = schedule[game];
        address _player = gameInstance.player0;
        uint256 _wager = gameInstance.wager;
        gameInstance.a = true;
        gameInstance.score = p0ws;
        if(p0w){
            exp.addValue(_player,gameInstance.char,gameInstance.stock);
            book[_player] += _wager * 95 / 100;
            gameInstance.w = true;
        } else {
            book[_player] -= _wager;
            losses[_player] += _wager;
            emit HouseWins(_wager);
        }
        schedule[game] = gameInstance;
        engagement[_player] = false;
    }

    function purchaseCredit(uint256 value) internal {
        book[msg.sender] += value;
    }

    function checkHealth() internal view returns(uint256){
        return ((address(this).balance - book[owner()]) * health / 10000);
    }
    
}