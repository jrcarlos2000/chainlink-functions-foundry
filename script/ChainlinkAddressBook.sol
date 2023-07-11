pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/dev/functions/FunctionsOracle.sol";
import "../src/dev/functions/FunctionsBillingRegistry.sol";
import "./Helpers.sol";

interface ILinkToken {
    function transferAndCall(
        address,
        uint256,
        bytes calldata
    ) external returns (bool success);
}

interface IFunctionsConsumer {
    function executeRequest(
        string calldata,
        bytes calldata,
        string[] calldata,
        uint64,
        uint32
    ) external returns (bytes32);
}

contract ChainlinkAddressBook is Helpers {
    mapping(uint256 => mapping(bytes32 => address)) public addresses;

    bytes32 constant FUNCTIONS_ORACLE_PROXY =
        keccak256("FUNCTIONS_ORACLE_PROXY");
    bytes32 constant FUNCTIONS_BILLING_REGISTRY_PROXY =
        keccak256("FUNCTIONS_BILLING_REGISTRY_PROXY");
    bytes32 constant LINK_TOKEN_ADDRESS = keccak256("LINK_TOKEN");

    function setUp() public override {
        super.setUp();
        // polygon mumbai
        addresses[80001][
            FUNCTIONS_ORACLE_PROXY
        ] = 0xeA6721aC65BCeD841B8ec3fc5fEdeA6141a0aDE4;
        addresses[80001][
            FUNCTIONS_BILLING_REGISTRY_PROXY
        ] = 0xEe9Bf52E5Ea228404bB54BCFbbDa8c21131b9039;
        addresses[80001][
            LINK_TOKEN_ADDRESS
        ] = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
    }

    function oracle() internal view returns (FunctionsOracle) {
        return
            FunctionsOracle(addresses[block.chainid][FUNCTIONS_ORACLE_PROXY]);
    }

    function registry() internal view returns (FunctionsBillingRegistry) {
        return
            FunctionsBillingRegistry(
                addresses[block.chainid][FUNCTIONS_BILLING_REGISTRY_PROXY]
            );
    }

    function linkToken() internal view returns (ILinkToken) {
        return ILinkToken(addresses[block.chainid][LINK_TOKEN_ADDRESS]);
    }
}
