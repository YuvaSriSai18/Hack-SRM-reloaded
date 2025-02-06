// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./MonopolyToken_ERC20.sol";

contract MonopolyProperty is ERC721URIStorage, Ownable {
    struct Property {
        uint256 boardId;
        uint256 price;
        uint256 rent;
        bool isMortgaged;
        address owner;
    }
    
    mapping(uint256 => Property) public properties;
    uint256 private nextPropertyId;
    
    event PropertyRegistered(uint256 propertyId, uint256 boardId, uint256 price, uint256 rent);
    event PropertyTransferred(uint256 propertyId, address from, address to);
    
    constructor() ERC721("MonopolyProperty", "MNP-NFT") Ownable(msg.sender) {}
    
    function registerProperty(uint256 boardId, uint256 price, uint256 rent) external onlyOwner {
        uint256 propertyId = nextPropertyId++;
        properties[propertyId] = Property(boardId, price, rent, false, address(this));
        _mint(address(this), propertyId);
        emit PropertyRegistered(propertyId, boardId, price, rent);
    }
    
    function transferProperty(uint256 propertyId, address newOwner) external {
        require(ownerOf(propertyId) == msg.sender, "Only owner can transfer");
        _transfer(msg.sender, newOwner, propertyId);
        properties[propertyId].owner = newOwner;
        emit PropertyTransferred(propertyId, msg.sender, newOwner);
    }
}