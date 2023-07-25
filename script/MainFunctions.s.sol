pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "./Utils.s.sol";
import "../src/FunctionsConsumer.sol";

contract MainFunctionsScript is
    CheckIsAllowedScript,
    CreateSubscriptionScript,
    FundSubscriptionScript,
    AddConsumerScript,
    ExecuteRequestScript
{
    function run()
        public
        override(
            CheckIsAllowedScript,
            CreateSubscriptionScript,
            FundSubscriptionScript,
            AddConsumerScript,
            ExecuteRequestScript
        )
    {
        startBroadcast();
        // STEP 1 : Create a subscription
        // uint64 subId = createSubscription();

        // NOTE : if you alredy have a funded subscription you can directly use it
        uint64 subId = 1897;

        // STEP 2 : Fund the subscription
        fundSubscription(subId, 20 ether);

        // STEP 3 : Deploy consumer contract
        // FunctionsConsumer consumer = new FunctionsConsumer(address(oracle()));

        // STEP 4 : Add consumer contract to subscription
        // addConsumer(subId, address(consumer));

        // STEP 5 : Execute a Request
        // executeRequest(
        //     address(consumer),
        //     subId,
        //     "calculation-example.js",
        //     new string[](0)
        // );

        // [OPTIONAL] : Check Subscription Data
        printSubscriptionInfo(subId);
        stopBroadcast();
    }
}
