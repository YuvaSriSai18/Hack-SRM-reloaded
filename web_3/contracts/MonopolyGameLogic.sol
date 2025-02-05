// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./MonopolyProperty.sol";

contract MonopolyGame is VRFConsumerBase, Ownable {
    struct Player {
        address wallet;
        uint256 balance;
        uint256 position;
        bool isBankrupt;
    }

    struct Game {
        address[] players;
        mapping(address => Player) playerData;
        uint256 currentPlayerIndex;
        bool isActive;
    }

    mapping(uint256 => Game) public games;
    mapping(bytes32 => uint256) public diceRequests;
    MonopolyProperty public propertyContract;
    uint256 private fee;
    bytes32 private keyHash;

    event GameStarted(uint256 boardId, address[] players);
    event DiceRolled(uint256 boardId, address player, uint256 diceRoll);
    event PlayerMoved(uint256 boardId, address player, uint256 newPosition);
    event PropertyBought(uint256 boardId, uint256 propertyId, address buyer);
    event RentPaid(uint256 boardId, uint256 propertyId, address tenant, uint256 amount);
    event ChanceCardDrawn(uint256 boardId, address player, string message);
    event PlayerBankrupt(uint256 boardId, address player);
    event TurnEnded(uint256 boardId, address player);

    constructor(address _propertyContract, address _vrfCoordinator, address _linkToken, bytes32 _keyHash, uint256 _fee)
        VRFConsumerBase(_vrfCoordinator, _linkToken) {
        propertyContract = MonopolyProperty(_propertyContract);
        keyHash = _keyHash;
        fee = _fee;
    }

    /**
     * @dev Initializes a new game with players and sets up the board.
     */
    function startGame(uint256 boardId, address[] memory players) external onlyOwner {
        require(players.length >= 2, "At least two players required.");
        require(!games[boardId].isActive, "Game already active.");

        games[boardId].isActive = true;
        games[boardId].players = players;

        for (uint256 i = 0; i < players.length; i++) {
            games[boardId].playerData[players[i]] = Player(players[i], 1500, 0, false);
        }

        emit GameStarted(boardId, players);
    }

    /**
     * @dev Requests a random dice roll using Chainlink VRF.
     */
    function rollDice(uint256 boardId) external {
        require(games[boardId].isActive, "Game not active.");
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK.");

        bytes32 requestId = requestRandomness(keyHash, fee);
        diceRequests[requestId] = boardId;
    }

    /**
     * @dev Handles the Chainlink VRF response for a dice roll.
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        uint256 boardId = diceRequests[requestId];
        address currentPlayer = games[boardId].players[games[boardId].currentPlayerIndex];
        uint256 diceRoll = (randomness % 6) + 1; // Dice roll between 1-6

        emit DiceRolled(boardId, currentPlayer, diceRoll);
        movePlayer(boardId, currentPlayer, diceRoll);
    }

    /**
     * @dev Moves a player on the board.
     */
    function movePlayer(uint256 boardId, address player, uint256 steps) internal {
        Player storage p = games[boardId].playerData[player];
        require(!p.isBankrupt, "Player is bankrupt.");

        p.position = (p.position + steps) % 40; // Assuming 40 spaces on the board

        emit PlayerMoved(boardId, player, p.position);
    }

    /**
     * @dev Allows a player to buy a property.
     */
    function buyProperty(uint256 boardId, uint256 propertyId) external {
        address buyer = msg.sender;
        Player storage player = games[boardId].playerData[buyer];

        ( , uint256 price, , , address owner) = propertyContract.getPropertyDetails(propertyId);
        require(owner == address(0), "Property already owned.");
        require(player.balance >= price, "Not enough balance.");

        player.balance -= price;
        propertyContract.transferProperty(propertyId, buyer);

        emit PropertyBought(boardId, propertyId, buyer);
    }

    /**
     * @dev Handles rent payments.
     */
    function payRent(uint256 boardId, uint256 propertyId) external payable {
        ( , , uint256 rent, , address owner) = propertyContract.getPropertyDetails(propertyId);
        require(msg.value == rent, "Incorrect rent amount.");

        address tenant = msg.sender;
        Player storage tenantData = games[boardId].playerData[tenant];
        Player storage ownerData = games[boardId].playerData[owner];

        require(tenantData.balance >= rent, "Not enough balance.");

        tenantData.balance -= rent;
        payable(owner).transfer(rent);

        emit RentPaid(boardId, propertyId, tenant, rent);
    }

    /**
     * @dev Draws a random chance card for the player.
     */
    function drawChanceCard(uint256 boardId) external {
        require(games[boardId].isActive, "Game not active.");
        address player = games[boardId].players[games[boardId].currentPlayerIndex];

        string[5] memory cards = [
            "Advance to Go (Collect $200)",
            "Bank pays you dividend of $50",
            "Go to Jail (Do not pass Go, do not collect $200)",
            "Pay hospital fees of $100",
            "You have won a crossword competition (Collect $100)"
        ];

        uint256 randomIndex = (uint256(keccak256(abi.encodePacked(block.timestamp, player))) % 5);
        string memory selectedCard = cards[randomIndex];

        emit ChanceCardDrawn(boardId, player, selectedCard);
    }

    /**
     * @dev Declares a player bankrupt.
     */
    function declareBankruptcy(uint256 boardId) external {
        address player = msg.sender;
        Player storage p = games[boardId].playerData[player];

        require(p.balance == 0, "Player still has money.");
        p.isBankrupt = true;

        emit PlayerBankrupt(boardId, player);
    }

    /**
     * @dev Ends the current player's turn and moves to the next player.
     */
    function endTurn(uint256 boardId) external {
        require(games[boardId].isActive, "Game not active.");

        games[boardId].currentPlayerIndex = (games[boardId].currentPlayerIndex + 1) % games[boardId].players.length;
        address nextPlayer = games[boardId].players[games[boardId].currentPlayerIndex];

        emit TurnEnded(boardId, nextPlayer);
    }
}
