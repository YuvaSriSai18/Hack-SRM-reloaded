// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MonopolyToken is ERC20, Ownable {
    struct GameBoard {
        uint256 bankBalance;
        bool exists;
    }

    mapping(uint256 => GameBoard) public gameBoards;

    event GameBoardCreated(uint256 boardId);
    event TokensMinted(uint256 boardId, address[] players, uint256 amount);
    event TransferToBank(uint256 boardId, address from, uint256 amount);
    event TransferToPlayer(uint256 boardId, address from, address to, uint256 amount);
    event BurnBankrupt(uint256 boardId, address player, uint256 amount);

    constructor() ERC20("MonopolyToken", "MNY") Ownable(msg.sender) {
        _mint(msg.sender, 15000 * 10 ** 18);
    }

    function createGameBoard(uint256 boardId) external {
        require(!gameBoards[boardId].exists, "Board already exists");
        gameBoards[boardId] = GameBoard(15 * 10 ** 18, true);
        emit GameBoardCreated(boardId);
    }

    function mintToPlayers(uint256 boardId, address[] calldata players, uint256 amount) external {
        require(gameBoards[boardId].exists, "Board does not exist");

        for (uint256 i = 0; i < players.length; i++) {
            _mint(players[i], amount);
        }
        gameBoards[boardId].bankBalance += amount * players.length;
        emit TokensMinted(boardId, players, amount);
    }

    function transferToBank(uint256 boardId, address from, uint256 amount) external {
        require(gameBoards[boardId].exists, "Board does not exist");
        _transfer(from, address(this), amount);
        gameBoards[boardId].bankBalance += amount;
        emit TransferToBank(boardId, from, amount);
    }

    function transferToPlayer(uint256 boardId, address from, address to, uint256 amount) external {
        require(gameBoards[boardId].exists, "Board does not exist");
        _transfer(from, to, amount);
        emit TransferToPlayer(boardId, from, to, amount);
    }

    function burnBankrupt(uint256 boardId, address player) external {
        require(gameBoards[boardId].exists, "Board does not exist");
        uint256 balance = balanceOf(player);
        _burn(player, balance);
        emit BurnBankrupt(boardId, player, balance);
    }

    function getBankBalance(uint256 boardId) external view returns (uint256) {
        require(gameBoards[boardId].exists, "Board does not exist");
        return gameBoards[boardId].bankBalance;
    }
}
