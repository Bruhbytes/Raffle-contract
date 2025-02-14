// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {DeployRaffle} from "../script/DeployRaffle.s.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {Raffle} from "../src/Raffle.sol";

contract RaffleTest is Test{
    event enteredRaffle(address indexed player);

    address PLAYER = makeAddr("player");
    uint256 constant STARTING_BALANCE = 10 ether;

    Raffle public raffle;
    HelperConfig public helper;

    function setUp() public{        
        DeployRaffle deploy = new DeployRaffle();
        (raffle, helper) = deploy.run();    
        vm.deal(PLAYER, STARTING_BALANCE);    
    }

    function test_raffleInitializesInOpen() public{
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function test_raffleRevertsWhenYouDontPayEnough() public{
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle_NotEnoughETHSent.selector);
        raffle.enterRaffle();
    }

    function test_playerWhenEnteringRaffle() public{
        vm.prank(PLAYER);
        raffle.enterRaffle{value: 1 ether}();
        address player = raffle.getPlayer(0);
        assert(player == PLAYER);
    }

    function test_emitEventsOnEntrance() public{
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit enteredRaffle(PLAYER);        
        raffle.enterRaffle{value: 1 ether}();
    }
}
