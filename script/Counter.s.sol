// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/master.sol";
import "../src/chance.sol";
import "../src/ppexp.sol";
import "../src/fake/fakevrf.sol";

contract CounterScript is Script {
    fVRF _vrf;
    VRF _chance;
    PPOMaster _master;
    PPEXP1 _exp;
    address masterAdd;
    address chanceAdd;
    address vrfAdd;
    address expAdd;
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        // Deploy your contracts here and set them up
        //accounts[0] 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,
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
        uint32[6] memory team = [uint32(171),uint32(5),uint32(4),uint32(3),uint32(2),uint32(1)];
        _exp.register(team);
        vm.stopBroadcast();
    }
}