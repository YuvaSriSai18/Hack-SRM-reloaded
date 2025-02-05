// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Monopoly_Property_NFT.sol";

contract MonopolyBank {
    IERC20 public monopolyToken;
    MonopolyProperty public propertyContract;
    address public gameAdmin;

    struct Auction {
        uint propertyId;
        uint minBid;
        address highestBidder;
        uint highestBid;
        bool active;
    }

    mapping(uint => Auction) public auctions; // propertyId => Auction details
    mapping(address => uint) public balances; // Player balances
    uint public boardId;

    event PaymentReceived(address from, uint amount);
    event PaymentDistributed(address to, uint amount);
    event BankruptFundsBurned(address player, uint amount);
    event PropertyAuctionStarted(uint propertyId, uint minBid);
    event AuctionFinalized(uint propertyId, address winner, uint bidAmount);

    modifier onlyAdmin() {
        require(msg.sender == gameAdmin, "Not game admin");
        _;
    }

    constructor(uint _boardId, address _monopolyToken, address _propertyContract) {
        boardId = _boardId;
        monopolyToken = IERC20(_monopolyToken);
        propertyContract = MonopolyProperty(_propertyContract);
        gameAdmin = msg.sender;
    }

    function receivePayment(address from, uint amount) external {
        require(monopolyToken.transferFrom(from, address(this), amount), "Transfer failed");
        balances[address(this)] += amount;
        emit PaymentReceived(from, amount);
    }

    function distributeToPlayer(address to, uint amount) external onlyAdmin {
        require(balances[address(this)] >= amount, "Insufficient funds");
        balances[address(this)] -= amount;
        require(monopolyToken.transfer(to, amount), "Transfer failed");
        emit PaymentDistributed(to, amount);
    }

    function burnBankruptFunds(address player) external onlyAdmin {
        uint playerBalance = monopolyToken.balanceOf(player);
        if (playerBalance > 0) {
            monopolyToken.transferFrom(player, address(this), playerBalance);
            balances[address(this)] += playerBalance;
        }
        emit BankruptFundsBurned(player, playerBalance);
    }

    function auctionProperty(uint propertyId, uint minBid) external onlyAdmin {
        require(!auctions[propertyId].active, "Auction already exists");
        require(propertyContract.ownerOf(propertyId) != address(this), "Property is already owned by the bank");

        auctions[propertyId] = Auction({
            propertyId: propertyId,
            minBid: minBid,
            highestBidder: address(0),
            highestBid: 0,
            active: true
        });

        propertyContract.transferProperty(propertyId, address(this)); // Bank takes ownership
        emit PropertyAuctionStarted(propertyId, minBid);
    }

    function finalizeAuction(uint propertyId, address winner, uint bidAmount) external onlyAdmin {
        Auction storage auction = auctions[propertyId];
        require(auction.active, "Auction not active");
        require(auction.highestBidder == winner, "Not highest bidder");
        require(auction.highestBid == bidAmount, "Invalid bid amount");

        require(monopolyToken.transferFrom(winner, address(this), bidAmount), "Payment failed");
        balances[address(this)] += bidAmount;

        propertyContract.transferProperty(propertyId, winner); // Transfer NFT to winner
        auction.active = false;

        emit AuctionFinalized(propertyId, winner, bidAmount);
    }
}
