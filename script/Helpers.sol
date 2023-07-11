pragma solidity ^0.8.19;

import "forge-std/Script.sol";

contract Helpers is Script {
    uint256 private deployerPk;
    string private verbose;

    function setUp() public virtual {
        deployerPk = vm.envUint("DEPLOYER_PRIVATE_KEY");
        verbose = vm.envString("VERBOSE");
    }

    function startBroadcast() internal {
        vm.startBroadcast(deployerPk);
    }

    function deployerAddr() internal view returns (address) {
        return vm.addr(deployerPk);
    }

    function stopBroadcast() internal {
        vm.stopBroadcast();
    }

    function isVerbose() internal view returns (bool) {
        return
            (keccak256(bytes(verbose)) == keccak256(bytes("TRUE"))) ||
            (keccak256(bytes(verbose)) == keccak256(bytes("True"))) ||
            (keccak256(bytes(verbose)) == keccak256(bytes("true")));
    }
}
