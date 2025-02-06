// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./MonopolyToken_ERC20.sol";
import "./Monopoly_Property.sol";

contract MonopolyBank is Ownable {
    MonopolyToken public monopolyToken;
    MonopolyProperty public propertyContract;
    
    constructor(address tokenAddress, address propertyAddress) Ownable(msg.sender) {
        monopolyToken = MonopolyToken(tokenAddress);
        propertyContract = MonopolyProperty(propertyAddress);
    }
    
    function transferToPlayer(address player, uint256 amount) external onlyOwner {
        monopolyToken.transfer(player, amount);
    }
    
    function transferToBank(address player, uint256 amount) external {
        require(monopolyToken.transferFrom(player, address(this), amount), "Transfer failed");
    }
    
    function playerToPlayer(address from, address to, uint256 amount) external {
        require(monopolyToken.transferFrom(from, to, amount), "Transfer failed");
    }
}