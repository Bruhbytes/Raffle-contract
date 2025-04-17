//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract HelperConfig is Script{
    struct NetworkConfig{
        address vrf_coordinator;
        bytes32 gas_lane;
        uint32 callback_gaslimit;
        uint256 entrance_fees;
        uint256 interval;
        uint256 subscription_id;
        address link;
        address account;
    }

    NetworkConfig public activeConfig;

    constructor(){
        if(block.chainid == 11155111){
            activeConfig = getSepoliaConfig();
        }
        else{
            activeConfig = getOrCreateAnvilConfig();
        }
    }

    function getSepoliaConfig() internal pure returns(NetworkConfig memory){
        NetworkConfig memory sep = NetworkConfig({
            vrf_coordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            gas_lane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callback_gaslimit:400000,
            entrance_fees: 0.01 ether,
            interval: 60,
            subscription_id: 92899835631459027294541149648382698302472951653827755408127349112050177594964,
            link:0x779877A7B0D9E8603169DdbD7836e478b4624789,
            account: 0x0Aa721a6FD496742bb46C1dD6F857661Af2A9699
        });
        return sep;
    }

    function getOrCreateAnvilConfig() internal returns(NetworkConfig memory){
        if(activeConfig.vrf_coordinator != address(0)){
            return activeConfig;
        }

        uint96 baseFee = 0.25 ether;
        uint96 gasPrice = 1e9;
        int256 weiPerUnitLink = 1e18;

        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfmock = new VRFCoordinatorV2_5Mock(baseFee, gasPrice, weiPerUnitLink);        
        uint256 subscriptionId = vrfmock.createSubscription();
        LinkToken link = new LinkToken();
        vm.stopBroadcast();

        NetworkConfig memory anvil = NetworkConfig({
            vrf_coordinator: address(vrfmock),
            gas_lane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callback_gaslimit:250000,
            entrance_fees: 0.01 ether,
            interval: 60,
            subscription_id: subscriptionId,
            link: address(link),
            account: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 //anvil first account public address
        });
        return anvil;
    }

}