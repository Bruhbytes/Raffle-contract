# Proveable Random Raffle contracts

## What are raffle contracts?

Raffle contracts are legal agreements that outline the terms and conditions for conducting a raffle event. These contracts are typically used by organizations, charities, schools, clubs, or individuals who want to host a raffle to raise funds or offer prizes

## How a Raffle Works

- Ticket Sales: People purchase raffle tickets, and the proceeds go towards a specific cause—in this example, wildlife conservation.
- Prize Pool: There are prizes offered as incentives for people to buy tickets. These prizes can range from gift items, experiences, or even cash prizes.
- Drawing: On the specified date, a drawing is conducted to randomly select winners from the pool of ticket buyers.
- Winner Announcement: The winners are announced and notified, and they receive the prizes.

## Key Components of a Raffle Contract

- Parties Involved: Specifies the promoter (the person or organization organizing the raffle) and the participants.
- Prizes: Details the prizes being offered in the raffle.
- Ticket Sales: Information on ticket prices, sales methods, and refund policies.
- Eligibility: Criteria for who can participate in the raffle.
- Drawing Process: How the winners will be selected and the date of the drawing.
- Winner Notification: How winners will be informed of their prize.
- Legal Compliance: Ensures the raffle adheres to local laws and regulations.

## About

The code is about creating a proveable random smart contract lottery

## What we want it to do?

1. Users can enter by buying a ticket
    1. The ticket fees are going to the winner during the draw
2. After X period of time, the system will automatically draw a winner and this will be done programmatically
3. Using Chainlink VRF and Chainlink Automation
    - Chainlink VRF -> Randomness
    - Chainlink Automation -> Time based trigger
