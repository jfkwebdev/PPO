// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/lvl1.sol";
import "../src/ppexp.sol";
//import "../src/fake/fakevrf.sol";

contract CounterScript is Script {
    //fVRF _vrf;
    PPOMaster _master;
    PPEXP1 _exp;

    function run() external returns(address, PPOMaster, PPEXP1) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        // Deploy your contracts here and set them up
        //accounts[0] 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,
        //_vrf = new fVRF();
        //flow
        _master = new PPOMaster(69);

        //_vrf.setUp(address(_master));
        _exp = new PPEXP1();
        //address own = _exp.owner();
        //vm.prank(own);
        _exp.legalize(address(_master));
        _master.setExp(address(_exp));
        _master.setFee(100000000);
        _master.ignition();
        _master.nitro();
        uint32[6] memory team = [uint32(12),uint32(5),uint32(4),uint32(3),uint32(2),uint32(1)];
        _exp.register(team);
        vm.stopBroadcast();
        address own = _exp.owner();
        return (own, _master, _exp);
    }
}