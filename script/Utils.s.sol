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
        console.logString("");
        console.logString("");
        console.logString("");

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
