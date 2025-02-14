// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployRaffle is Script{
    function run() external returns(Raffle, HelperConfig){
        HelperConfig helperConfig = new HelperConfig();
        (
            address vrf_coordinator,
            bytes32 gas_lane,
            uint32 callback_gaslimit,
            uint256 entrance_fees,
            uint256 interval,
            uint256 subscription_id
        ) = helperConfig.activeConfig();

        vm.startBroadcast();
        Raffle raffle = new Raffle(vrf_coordinator, gas_lane, callback_gaslimit, entrance_fees, interval, subscription_id);
        vm.stopBroadcast();
        
        return (raffle, helperConfig);
    }
}

