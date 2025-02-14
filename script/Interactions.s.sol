// SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

//Creating subscription programmatically
contract CreateSubscription is Script {
    

    function run() external returns (uint256) {
        HelperConfig helperconfig = new HelperConfig();
        (address vrf_coordinator, , , , , ) = helperconfig.activeConfig();

        uint256 s_subscriptionID;
        address LINK_TOKEN_CONTRACT = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

        vm.startBroadcast();
        //Create a subscripton
        IVRFCoordinatorV2Plus s_vrfcoordinator = IVRFCoordinatorV2Plus(vrf_coordinator);
        s_subscriptionID = s_vrfcoordinator.createSubscription();
        console.log("Subscription ID", s_subscriptionID);        

        //Fund the subscripton ID
        LinkTokenInterface LinkToken = LinkTokenInterface(LINK_TOKEN_CONTRACT);
        LinkToken.transferAndCall(address(vrf_coordinator), 3 ether, abi.encode(s_subscriptionID));
        console.log("Funded Subscription with 3 LINK");

        //Get recently deployed smart lottery contract and add it as a consumer
        address recent = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);
        console.log("Recent Deployment is: ", recent);
        s_vrfcoordinator.addConsumer(s_subscriptionID, recent);

        vm.stopBroadcast();
    }
    
}
