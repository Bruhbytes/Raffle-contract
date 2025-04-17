// SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

//Creating subscription programmatically
contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() internal returns(uint256){
        uint256 s_subscriptionID;        
        console.log("Creating subscription on chainId: ", block.chainid);

        HelperConfig helperconfig = new HelperConfig();
        (address vrf_coordinator, , , , , , , address account) = helperconfig.activeConfig();

        vm.startBroadcast(account);
        if(block.chainid == 11155111){
            IVRFCoordinatorV2Plus s_vrfcoordinator = IVRFCoordinatorV2Plus(vrf_coordinator);
            s_subscriptionID = s_vrfcoordinator.createSubscription();
            console.log("Subscription ID", s_subscriptionID);
        }
        else{
            s_subscriptionID = VRFCoordinatorV2_5Mock(vrf_coordinator).createSubscription();
            console.log("Subscription ID", s_subscriptionID);
        }
        vm.stopBroadcast();

        return (s_subscriptionID);
    }

    function run() external returns (uint256) {
        return createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script{

    function fundSubscriptionConfig() internal{
        HelperConfig helperconfig = new HelperConfig();
        (address vrf_coordinator, , , , , uint256 subscription_id, address link, address account) = helperconfig.activeConfig();
        if(subscription_id == 0){
            CreateSubscription createSubscription = new CreateSubscription();
            subscription_id = createSubscription.run();
        }

        fundSubscription(vrf_coordinator, subscription_id, link, account);
    }
    function fundSubscription(address vrf_coordinator, uint256 subscription_id, address link, address account) internal {
        console.log("Funding subscription: ", subscription_id);
        console.log("Using vrfCoordinator: ", vrf_coordinator);
        console.log("On ChainID: ", block.chainid);
        if(block.chainid == 11155111){
            vm.startBroadcast();
            LinkTokenInterface LinkToken = LinkTokenInterface(link);
            LinkToken.transferAndCall(
                address(vrf_coordinator),
                10 ether,
                abi.encode(subscription_id)
            );
            vm.stopBroadcast();
        }
        else{
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrf_coordinator).fundSubscription(subscription_id, 10 ether);
            vm.stopBroadcast();
        }
        console.log("Funded Subscription with 3 LINK");
    }
    function run() external{
        fundSubscriptionConfig();
    }
}

contract AddConsumer is Script {
    function addConsumerUsingConfig(address recent) internal {
        HelperConfig helperconfig = new HelperConfig();
        (
            address vrf_coordinator,
            ,
            ,
            ,
            ,
            uint256 subscription_id,
            ,
        ) = helperconfig.activeConfig();

        console.log("On Chain", block.chainid);
        console.log("Adding consumer with address: ", recent);

        IVRFCoordinatorV2Plus s_vrfcoordinator = IVRFCoordinatorV2Plus(vrf_coordinator);
        vm.startBroadcast();
        s_vrfcoordinator.addConsumer(subscription_id, recent);
        vm.stopBroadcast();
        console.log("Subscription added successfully");
    }

    function run() external{
        address recent = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        console.log("Recent Deployment is: ", recent);
        addConsumerUsingConfig(recent);
    }
}
