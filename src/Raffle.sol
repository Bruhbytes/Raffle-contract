// --------------Solidity Layout------------
// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions
// -----------------------------------------

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

import {console} from "forge-std/console.sol";

/**
 * @title A simple Raffle contract
 * @author Dhruvil Suthar
 * @notice This contract is for creating a simple raffle
 * @dev Implements Chainlink VRFv2
 */
contract Raffle is VRFConsumerBaseV2Plus{
    error Raffle_NotEnoughETHSent();
    error Raffle_Closed();
    error Raffle__TransferFailed();
    error Raffle_UpKeepNotNeeded(RaffleState state, uint256 balance, uint256 players);
    
    /* Type Declarations */
    enum RaffleState {OPEN, CALCULATING}
    
    
    /* State Variables */    
    uint32 constant public NUM_WORDS = 2;
    uint16 constant public REQUESTCONFIRMATIONS = 3;
    LinkTokenInterface LINKTOKEN = LinkTokenInterface(0x779877A7B0D9E8603169DdbD7836e478b4624789);
    
    bytes32 immutable public i_gas_lane;
    uint32 immutable public i_callback_limit;
    uint256 immutable i_entranceFees;
    uint256 immutable public i_interval;
    uint256 immutable i_subscriptionID;

    uint256 public s_requestID;
    address payable[] s_players;
    uint256 s_lastTimeStamp;
    RaffleState s_raffleState;
    uint256[] public s_randomWords;
    address s_recentWinner;

    /* Events */
    event enteredRaffle(address indexed player);
    event WinnerPicked(address indexed player);

    constructor(
        address vrf_coordinator, 
        bytes32 gasLane,
        uint32 callBackGasLimit,
        uint256 fees, 
        uint256 interval, 
        uint256 subscription)VRFConsumerBaseV2Plus(vrf_coordinator){

        s_vrfCoordinator = IVRFCoordinatorV2Plus(vrf_coordinator);

        i_gas_lane = gasLane;
        i_callback_limit = callBackGasLimit;
        i_entranceFees = fees;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_subscriptionID = subscription;
        s_raffleState = RaffleState.OPEN;
    }

    

    function fulfillRandomWords(uint256 /* requestId */, uint256[] calldata randomWords) internal override{
        s_randomWords = randomWords;
        uint256 indexWinner = s_randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexWinner];
        s_recentWinner = recentWinner;
        s_players = new address payable[](0);
        s_raffleState = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp;

        (bool success,) = recentWinner.call{value: address(this).balance}("");
        if(!success){
            revert Raffle__TransferFailed();
        }
        emit WinnerPicked(recentWinner);
    }
    
    function enterRaffle() public payable{
        // require(msg.value < i_entranceFees, "Not enough ETH sent");
        if(msg.value < i_entranceFees){
            revert Raffle_NotEnoughETHSent();
        }        
        if(s_raffleState != RaffleState.OPEN){
            revert Raffle_Closed();
        }
        s_players.push(payable(msg.sender));
        emit enteredRaffle(msg.sender);
    }

    /**
    * @dev This function will check whether enough time has passed and will give permission to
    call the VRF Chainlink Node to give random words
    It will return true when the following is true:
    1. Specified interval has passed
    2. There are players in this Raffle
    3. The Raffle is in OPEN state
    4. (implicitly) the subscription is funded with enough LINK
     */
    function checkUpKeep() public view returns(bool, bytes memory /*performData*/){
        bool timePassed = (block.timestamp - s_lastTimeStamp) >= i_interval;
        bool state = RaffleState.OPEN == s_raffleState;
        bool hasPlayers = s_players.length > 0;
        bool hasBalance = address(this).balance > 0;

        bool upKeepNeeded = (timePassed && state && hasBalance && hasPlayers);
        return (upKeepNeeded, "0x0");
    }
    
    /**
     * @dev This function checks whether upKeep function has output true
        It requests VRF on Chainlink node to give the random number which in turn 
        will call fullfillRandomWords function
     */
    function performUpKeep(bytes calldata /* performData */) external {
        (bool upKeepNeeded, ) = checkUpKeep();
        console.log(upKeepNeeded);
        if(!upKeepNeeded){
            revert Raffle_UpKeepNotNeeded(s_raffleState, address(this).balance, s_players.length);
        }
        
        s_raffleState = RaffleState.CALCULATING;

        
        s_requestID = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_gas_lane,
                subId: i_subscriptionID,
                requestConfirmations: REQUESTCONFIRMATIONS,
                callbackGasLimit: i_callback_limit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
        console.log(s_requestID);
        console.log("performUpKeep successfully done");
    }

    function topUpSubscription(uint256 amount) external{
        LINKTOKEN.transferAndCall(address(s_vrfCoordinator), amount, abi.encode(i_subscriptionID));
    }

    //Getter functions
    function getFees() external view returns(uint256){
        return i_entranceFees;
    }

    function getRaffleState() external view returns(RaffleState){
        return s_raffleState;
    }

    function getPlayer(uint index) external view returns(address){
        return s_players[index];
    }
}

