//SPDX-License-Identifier: VPL

pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../script/Counter.s.sol";
import "../src/lvl1.sol";
import "../src/ppexp.sol";
//import "../src/fake/fakevrf.sol";

contract ContractInteractionTest is Test {
    CounterScript script = new CounterScript();
    //fVRF _vrf;
    PPOMaster _master;
    PPEXP1 _exp;
    
    address user = address(69);
    address admin;

    struct Team {
        uint32 first;
        uint32 second;
        uint32 third;
        uint32 fourth;
        uint32 fifth;
        uint32 sixth;
    }

    ///////
    // internal test functions
    //////

    function setUp() public {
        (admin, _master, _exp) = script.run();
    }

    function testSetUp() public {
        (admin, _master, _exp) = script.run();
        assertNotEq(address(_master),address(0));
    }

    function test_1_ContractInitialization() view public {
        // Write test logic to check that contract addresses are set correctly
        console.logAddress(address(_exp));
        console.logAddress(admin);
        console.logAddress(address(_master));
    }

    // function play(uint32 seed,uint32 stocks) public returns(uint256 id) {
    //     uint256 game = _master.sponsor{value: 1000000000}(user,1,1,stocks);
    //     vm.prank(address(1));
    //     _vrf.handleRequest(game,stocks*2,seed);
    //     return game;
    // }

    // function lose(uint32 stocks) public returns(uint256 id) {
    //     uint256 game = _master.sponsor{value: 1000000000}(user,1,1,stocks);
    //     vm.prank(address(1));
    //     _vrf.handleLoseRequest(game,stocks*2);
    //     return game;
    // }

    // function win(uint32 stocks) public returns(uint256 id) {
    //     uint256 game = _master.sponsor{value: 1000000000}(user,1,1,stocks);
    //     vm.prank(address(1));
    //     _vrf.handleWinRequest(game,stocks*2);
    //     return game;
    // }

    /////////////
    // GateKeeping
    ////////////

    /*

    exp:
        onlyOwner
            adminRegister (lets make an admin register so that eventually it can accept players registering)
            setWin
            withdraw
        authorized
            [lvls]
                addValue
            level30pack owners
                knight
            ccip
                register

    lvl1
        onlyOwner
            setExp
        authorized
            fulfillrandomRequest
            vrf config

    

    */

    ////////////////
    // full tests //
    ////////////////

    // function test1PlayError(uint32 seed, uint32 stocks) public {
    //     vm.assume(seed < 100 && seed > 20);
    //     vm.assume(stocks < 5 && stocks > 0);
    //     uint256 game = 400;
    //     _master.sponsor{value: 1000000000}(user,1,1,stocks);
    //     vm.prank(address(1));
    //     vm.expectRevert();
    //     _vrf.handleRequest(game,stocks*2,seed);
    // }

    // function test1Play(uint32 seed, uint32 stocks) public {
    //     vm.assume(seed < 100 && seed > 20);
    //     vm.assume(stocks < 5 && stocks > 0);
    //     uint256 id = play(seed,stocks);
    //     bool dub = _master.readDub(id);
    //     if(dub){
    //         assertEq(_exp.ranking(user,1),100*stocks);
    //     } else {
    //         assertEq(_exp.ranking(user,1),0);
    //     }
    // }

    // function test1WinPlay(uint32 stocks) public {
    //     vm.assume(stocks < 5 && stocks > 0);
    //     uint256 id = win(stocks);
    //     bool dub = _master.readDub(id);
    //     assertEq(dub,true);
    // }


    ///////
    //master tests//
    ///////

    // function testreadSchedule(uint32 seed, uint32 stocks) public {
    //     vm.assume(seed < 100 && seed > 20);
    //     vm.assume(stocks < 5 && stocks > 0);
    //     uint256 id = play(seed, stocks);
    //     bool a = _master.readSchedule(id).a;
    //     assertEq(a,true);
    // }

    // function testReadActivity(uint32 seed, uint32 stocks) public {
    //     vm.assume(seed < 100 && seed > 20);
    //     vm.assume(stocks < 5 && stocks > 0);
    //     play(seed, stocks);
    //     console.log(_master.readActivity());
    //     assertEq(_master.readActivity(),1);
    // }

    function testSetExp(address testExp) public {
        vm.prank(admin);
        _master.setExp(testExp);
    }

    function testSetExpGate(address testExp) public {
        vm.expectRevert();
        _master.setExp(testExp);
    }

    // function testLose(uint32 stocks) public {
    //     vm.assume(stocks < 5 && stocks > 0);
    //     uint256 game = lose(stocks);
    //     assertEq(_master.readDub(game),false);
    // }

    // function testWin(uint32 stocks) public {
    //     vm.assume(stocks < 5 && stocks > 0);
    //     uint256 game = win(stocks);
    //     assertEq(_master.readDub(game),true);
    //     uint32 xp = _exp.readExp(user,1);
    //     assertEq(xp,stocks*100);
    // }

    /////
    // exp tests
    //////

    // function testKnight() public {
    //     uint32[6] memory newTeam = [uint32(1),uint32(2),uint32(3),uint32(4),uint32(5),uint32(6)];
    //     string memory name = "POOPOOMAN";
    //     vm.prank(user);
    //     _exp.register(newTeam);
    //     _exp.makeLevel30(user,1);
    //     vm.prank(user);
    //     _exp.knight(1,name);
    //     assertEq(_exp.readRoster(user,1),name);
    // }


    function testKnightLevelGate() public {
        uint32[6] memory newTeam = [uint32(1),uint32(2),uint32(3),uint32(4),uint32(5),uint32(6)];
        string memory name = "POOPOOMAN";
        vm.prank(user);
        _exp.register(newTeam);
        vm.prank(user);
        vm.expectRevert();
        _exp.knight(1,name);
        assertEq(_exp.readRoster(user,1),"");
    }

    function testReadRegistrar() public {
        uint32[6] memory newTeam = [uint32(1),uint32(2),uint32(3),uint32(4),uint32(5),uint32(6)];
        vm.prank(user);
        _exp.register(newTeam);
        uint32 first = _exp.readRegistrar(user)[0];
        assertEq(first,1);
    }

    // function testSetWin(uint32 newWin, uint32 stocks) public {
    //     vm.assume(stocks < 5 && stocks > 0);
    //     vm.assume(newWin < 1000000000);
    //     vm.prank(user);
    //     _exp.setWin(newWin);
    //     uint256 game = win(stocks);
    //     assertEq(_master.readDub(game),true);
    //     uint32 xp = _exp.readExp(user,1);
    //     assertEq(xp,stocks* newWin);
    // }

    function testSetWinGate(uint32 newWin) public {
        vm.assume(newWin >= 1000000000);
        vm.expectRevert();
        _exp.setWin(newWin);
    }

    function testNoDuplicate() public {
        uint32[6] memory badTeam = [uint32(4),uint32(4),uint32(5),uint32(6),uint32(7),uint32(8)];
        vm.expectRevert();
        vm.prank(user);
        _exp.register(badTeam);
    }

    function testRegister() public {
        uint32[6] memory goodTeam = [uint32(3),uint32(4),uint32(5),uint32(6),uint32(7),uint32(8)];
        vm.prank(user);
        _exp.register(goodTeam);
        assertEq(goodTeam[3],_exp.readRegistrar(user)[3]);
    }

    function testCanonGate() public {
        uint32[6] memory goodTeam = [uint32(3),uint32(4),uint32(5),uint32(6),uint32(7),uint32(8)];
        vm.prank(user);
        _exp.register(goodTeam);
        vm.expectRevert();
        string memory userName = "BIG MAN";
        vm.prank(user);
        _exp.incorporate(userName);
    }

    // function testCanon() public {
    //     uint32[6] memory goodTeam = [uint32(3),uint32(4),uint32(5),uint32(6),uint32(7),uint32(8)];
    //     vm.prank(user);
    //     _exp.register(goodTeam);
    //     _exp.makeLevel30(user,3);
    //     string memory userName = "BIG MAN";
    //     vm.prank(user);
    //     _exp.incorporate(userName);
    //     assertEq(_exp.readCanon(user),userName);
    // }

    function testCooldown() public {
        vm.deal(user,10000000000000000);
        vm.prank(user);
        _master.load{value: 10000000000000000}();
        uint256 game = _master.sponsor{value: 100000000}(user,1,1,3,0);
        vm.expectRevert();
        uint256 game2 = _master.sponsor{value: 100000000}(user,1,1,3,0);
    }

    function testCool() public {
        vm.deal(user,10000000000000000);
        vm.prank(user);
        _master.load{value: 10000000000000000}();
        uint256 game = _master.sponsor{value: 100000000}(user,1,1,3,0);
        vm.warp(block.timestamp + 15*3 + 1);
        uint256 game2 = _master.sponsor{value: 100000000}(user,1,1,3,0);
        assertEq(game,game2);
    }

        // function play(uint32 seed,uint32 stocks) public returns(uint256 id) {
    //     uint256 game = _master.sponsor{value: 1000000000}(user,1,1,stocks);
    //     vm.prank(address(1));
    //     _vrf.handleRequest(game,stocks*2,seed);
    //     return game;
    // }

}
