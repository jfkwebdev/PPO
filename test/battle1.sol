//SPDX-License-Identifier: VPL

pragma solidity ^0.8.0;

import "forge-std/Test.sol";
// import "forge-std/Console.sol";

// Import the contract artifacts for your contracts
import "../src/chance.sol";
import "../src/master.sol";
import "../src/ppexp.sol";
import "../src/fake/fakevrf.sol";

contract ContractInteractionTest is Test {
    fVRF _vrf;
    VRF _chance;
    PPOMaster _master;
    PPEXP1 _exp;
    address masterAdd;
    address chanceAdd;
    address vrfAdd;
    address expAdd;

    struct Gamet {
        address player0;
        uint32 char;
        uint32 stock;
        bool a;
        bool w;
        bool[10] score;
    }

    function setUp() public {
        // Deploy your contracts here and set them up
        _vrf = new fVRF();
        vrfAdd = address(_vrf);
        //flow
        _master = new PPOMaster();
        masterAdd = address(_master);
        _chance = new VRF(vrfAdd,masterAdd);
        chanceAdd = address(_chance); //
        _vrf.setUp(chanceAdd);
        _exp = new PPEXP1(masterAdd);
        expAdd = address(_exp);
        _master.setExp(expAdd);
        _master.setChance(chanceAdd);
        //_lvl1 = new PPO1(expAdd, masterAdd);
        //lvl1Add = address(_lvl1);
    }

    function test_1_ContractInitialization() view public {
        // Write test logic to check that contract addresses are set correctly
        console.logAddress(expAdd);
        console.logAddress(vrfAdd);
        console.logAddress(masterAdd);
        console.logAddress(chanceAdd);
        //console.logAddress(lvl1Add);
    }

    function play(uint32 seed,uint32 stocks) public returns(uint256 id) {
        vm.assume(seed < 100 && seed > 20);
        _vrf.setRandomness(seed);
        //vm.prank(address(5));
        //_lvl1.play(1,1,3);
        uint256 game = _master.arm(address(5),1,1,stocks);
        vm.prank(address(1));
        _vrf.handleRequest(stocks*2,id);
        return game;
    }

    // function test_2_RequestRandomness(uint256 seed) public {
    //     play(seed);
    // }
    // function getDub(uint256 gameId) internal returns(bool) {
    //     Gamet memory instance = _master.schedule(gameId);
    //     return instance.w;
    // }

    function test_3_FavorableRandomnessOutcome(uint32 seed) public {
        // Write test logic to verify that favorable randomness outcomes result in value added in Exp contract
        uint32 stocks = 3;
        uint256 id = play(seed,stocks);
        bool dub = _master.readDub(id);
    
        if(dub){
            assertEq(_exp.ranking(address(5),1),100*stocks);
        } else {
            assertEq(_exp.ranking(address(5),1),0);
        }
    }

    // Add the rest of the test functions here, covering all 30 scenarios as per your descriptions

    // function test_4_UnfavorableRandomnessOutcome() {}
    // function test_5_MultipleFavorableOutcomes() {}
    // function test_6_RequestRandomnessFromDifferentAddresses() {}
    // function test_7_FavorableOutcomeFromDifferentAddresses() {}
    // function test_8_UnfavorableOutcomeFromDifferentAddresses() {}
    // function test_9_EdgeCase_NoRandomnessRequest() {}
    // function test_10_EdgeCase_NoFavorableOutcomes() {}
    // ...

    // Test the interactions between your contracts in each scenario

    // function test_31_RandomnessRequestAfterUpgrades() public {
    //     // Write test logic to ensure that interactions still work correctly after contract upgrades
    // }

    // function test_32_EdgeCase_RequestFromUnauthorizedAddress() public {
    //     // Write test logic to verify that only authorized addresses can request randomness
    // }

    // Add the remaining test functions for edge cases and specific scenarios

    // function test_33_EdgeCase_NegativePredeterminedAmount() {}
    // function test_34_EdgeCase_AddressWithNoFavorableOutcomes() {}
    // ...

}
