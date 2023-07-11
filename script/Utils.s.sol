// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
import "forge-std/Vm.sol";
import "../src/dev/functions/FunctionsOracle.sol";
import "../src/dev/functions/FunctionsBillingRegistry.sol";
import "../src/FunctionsConsumer.sol";
import "./ChainlinkAddressBook.sol";

contract CheckIsAllowedScript is ChainlinkAddressBook {
    function run() public virtual {
        bool isAllowed = checkIsAllowed();
        if (isVerbose()) {
            console.logString("----------Deployer is Allowed----------");
            console.logBool(isAllowed);
        }
    }

    function checkIsAllowed() internal view returns (bool) {
        return oracle().isAuthorizedSender(deployerAddr());
    }
}

contract CreateSubscriptionScript is ChainlinkAddressBook {
    function run() public virtual {
        startBroadcast();
        createSubscription();
        stopBroadcast();
    }

    function createSubscription() internal returns (uint64 subId) {
        vm.recordLogs();
        registry().createSubscription();
        Vm.Log[] memory entries = vm.getRecordedLogs();
        if (isVerbose()) {
            console.logString("----------Deployed SubId----------");
            console.logUint(uint256(entries[0].topics[1]));
        }
        subId = uint64(uint256(entries[0].topics[1]));
    }

    function printSubscriptionInfo(uint64 subId) internal view {
        console.logString(
            "------------------ Subscription DATA ------------------"
        );
        console.logString(
            "------------------ Subscription DATA ------------------"
        );
        (uint96 balance, address owner, address[] memory consumers) = registry()
            .getSubscription(subId);
        console.logString("--------- Subscription ID ---------");
        console.logUint(subId);
        console.logString("--------- Balance ---------");
        console.logUint(balance);
        console.logString("--------- Owner ---------");
        console.logAddress(owner);
        console.logString("--------- Consumers ---------");
        for (uint256 i = 0; i < consumers.length; i++) {
            console.logAddress(consumers[i]);
        }
    }
}

contract FundSubscriptionScript is ChainlinkAddressBook {
    function run() public virtual {
        uint64 subId = 0; // TODO: FILL IN SUB ID
        uint256 amount = 0; // TODO: FILL IN AMOUNT
        startBroadcast();
        fundSubscription(subId, amount);
        stopBroadcast();
    }

    function fundSubscription(uint64 subId, uint256 amount) internal {
        linkToken().transferAndCall(
            address(registry()),
            amount,
            abi.encode(subId)
        );
        if (isVerbose()) {
            console.logString("----------Subscription Funded----------");
            console.logUint(amount);
        }
    }
}

contract AddConsumerScript is ChainlinkAddressBook {
    function run() public virtual {
        startBroadcast();
        uint64 subId = 0; // TODO: FILL IN SUB ID
        address consumerAddr = address(0); // TODO: FILL IN AMOUNT
        addConsumer(subId, consumerAddr);
        stopBroadcast();
    }

    function addConsumer(uint64 subId, address consumerAddr) internal {
        registry().addConsumer(subId, consumerAddr);
        if (isVerbose()) {
            console.logString("----------Consumer Added----------");
            console.logAddress(consumerAddr);
        }
    }
}

contract ExecuteRequestScript is ChainlinkAddressBook {
    function run() public virtual {
        startBroadcast();
        uint64 subId = 0; // TODO: FILL IN SUB ID
        address consumerAddr = address(0); // TODO: FILL IN CONSUMER ADDR
        string memory fileName = ""; // TODO: FILL FILENAME
        string[] memory args; // TODO: FILL IN ARGS

        executeRequest(consumerAddr, subId, fileName, args);
        stopBroadcast();
    }

    function executeRequest(
        address consumerAddr,
        uint64 subId,
        string memory fileName,
        string[] memory args
    ) internal returns (bytes32 requestId) {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/inline-requests/");
        path = string.concat(path, fileName);
        string memory jsFile = vm.readFile(path);
        IFunctionsConsumer(consumerAddr).executeRequest(
            jsFile,
            bytes(""),
            args,
            subId,
            300000
        );
        if (isVerbose()) {
            console.logString("----------Request Executed----------");
            console.logBytes32(requestId);
        }
    }
}

// contract CreateSubscriptionScript is Script {
//     address constant FUNCTIONS_BILLING_REGISTRY_PROXY =
//         0xEe9Bf52E5Ea228404bB54BCFbbDa8c21131b9039;
//     address constant FUNCTIONS_ORACLE_PROXY =
//         0xeA6721aC65BCeD841B8ec3fc5fEdeA6141a0aDE4;
//     address constant LINK_TOKEN_ADDRESS =
//         0x326C977E6efc84E512bB9C30f76E30c160eD06FB;

//     FunctionsBillingRegistry registry;
//     ILinkToken linkToken;
//     address public functionsConsumerAddr;

//     uint256 INITIAL_SUBSCRIPTION_BALANCE = 5 ether;

//     function run() public {
//         uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
//         vm.startBroadcast(deployerPrivateKey);
//         registry = FunctionsBillingRegistry(FUNCTIONS_BILLING_REGISTRY_PROXY);
//         vm.recordLogs();
//         registry.createSubscription();
//         Vm.Log[] memory entries = vm.getRecordedLogs();
//         uint64 subId = uint64(uint256(entries[0].topics[1]));
//         // uint64 subId = 1893;
//         addConsumer(subId);
//         if (INITIAL_SUBSCRIPTION_BALANCE > 0) {
//             fundSubscription(subId);
//         }
//         executeRequest(FunctionsConsumer(functionsConsumerAddr), subId);
//         printSubscriptionInfo(subId);
//         vm.stopBroadcast();
//     }

//     function addConsumer(uint64 subId) internal {
//         functionsConsumerAddr = deployConsumerContract();
//         registry.addConsumer(subId, functionsConsumerAddr);
//     }

//     function deployConsumerContract() internal returns (address) {
//         FunctionsConsumer functionsConsumer = new FunctionsConsumer(
//             FUNCTIONS_ORACLE_PROXY
//         );
//         return address(functionsConsumer);
//     }

//     function fundSubscription(uint64 subId) internal {
//         linkToken = ILinkToken(LINK_TOKEN_ADDRESS);
//         linkToken.transferAndCall(
//             address(registry),
//             INITIAL_SUBSCRIPTION_BALANCE,
//             abi.encode(subId)
//         );
//     }

//     function printSubscriptionInfo(uint64 subId) internal view {
//         (uint96 balance, address owner, address[] memory consumers) = registry
//             .getSubscription(subId);
//         console.logString("--------- Subscription ID ---------");
//         console.logUint(subId);
//         console.logString("--------- Balance ---------");
//         console.logUint(balance);
//         console.logString("--------- Owner ---------");
//         console.logAddress(owner);
//         console.logString("--------- Consumers ---------");
//         for (uint256 i = 0; i < consumers.length; i++) {
//             console.logAddress(consumers[i]);
//         }
//     }

//     function executeRequest(
//         FunctionsConsumer functionsConsumer,
//         uint64 subId
//     ) internal {
//         string memory root = vm.projectRoot();
//         string memory path = string.concat(
//             root,
//             "/inline-requests/calculation-example.js"
//         );
//         string memory jsFile = vm.readFile(path);
//         string[] memory args;
//         functionsConsumer.executeRequest(
//             jsFile,
//             bytes(""),
//             args,
//             subId,
//             300000
//         );
//     }
// }
