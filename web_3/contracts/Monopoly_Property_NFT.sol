// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MonopolyProperty is ERC721URIStorage {
    struct Property {
        uint256 boardId;
        uint256 price;
        uint256 rent;
        bool isMortgaged;
    }

    mapping(uint256 => Property) public properties;
    uint256 private nextPropertyId;

    event PropertyRegistered(
        uint256 propertyId,
        uint256 boardId,
        uint256 price,
        uint256 rent,
        address owner
    );
    event PropertyTransferred(uint256 propertyId, address from, address to);
    event MortgageStatusChanged(uint256 propertyId, bool isMortgaged);
    event RentPaid(uint256 propertyId, address tenant, uint256 amount);

    constructor() ERC721("MonopolyProperty", "MNP") {}

    function registerProperty(
        uint256 boardId,
        uint256 price,
        uint256 rent,
        address owner,
        string memory tokenURI
    ) external {
        uint256 propertyId = nextPropertyId++;
        properties[propertyId] = Property(boardId, price, rent, false);
        _mint(owner, propertyId);
        _setTokenURI(propertyId, tokenURI);
        emit PropertyRegistered(propertyId, boardId, price, rent, owner);
    }

    function transferProperty(uint256 propertyId, address newOwner) external {
        require(ownerOf(propertyId) == msg.sender, "Not the property owner");
        _transfer(msg.sender, newOwner, propertyId);
        emit PropertyTransferred(propertyId, msg.sender, newOwner);
    }

    function setMortgage(uint256 propertyId, bool status) external {
        require(ownerOf(propertyId) == msg.sender, "Not the property owner");
        properties[propertyId].isMortgaged = status;
        emit MortgageStatusChanged(propertyId, status);
    }

    function payRent(uint256 propertyId, address tenant) external payable {
        require(
            msg.value == properties[propertyId].rent,
            "Incorrect rent amount"
        );
        address owner = ownerOf(propertyId);
        payable(owner).transfer(msg.value);
        emit RentPaid(propertyId, tenant, msg.value);
    }

    function getPropertyDetails(uint256 propertyId)
        external
        view
        returns (
            uint256 boardId,
            uint256 price,
            uint256 rent,
            bool isMortgaged,
            address owner
        )
    {
        Property memory property = properties[propertyId];
        return (
            property.boardId,
            property.price,
            property.rent,
            property.isMortgaged,
            ownerOf(propertyId)
        );
    }
}
