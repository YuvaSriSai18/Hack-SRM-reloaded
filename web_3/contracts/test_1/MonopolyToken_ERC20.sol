// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MonopolyToken is ERC20, Ownable {
    struct GameBoard {
        uint256 bankBalance;
        bool exists;
    }
    
    mapping(uint256 => GameBoard) public gameBoards;
    event GameBoardCreated(uint256 boardId);
    event TokensMinted(uint256 boardId, address[] players, uint256 amount);
    
    constructor() ERC20("MonopolyToken", "MNP") Ownable(msg.sender) {}
    
    function createGameBoard(uint256 boardId, uint256 initialBankSupply, address[] memory players, uint256 playerInitialFunds) external onlyOwner {
        require(!gameBoards[boardId].exists, "Game board already exists");
        gameBoards[boardId] = GameBoard(initialBankSupply, true);
        _mint(address(this), initialBankSupply);
        for (uint i = 0; i < players.length; i++) {
            _mint(players[i], playerInitialFunds);
        }
        emit GameBoardCreated(boardId);
        emit TokensMinted(boardId, players, playerInitialFunds);
    }
}