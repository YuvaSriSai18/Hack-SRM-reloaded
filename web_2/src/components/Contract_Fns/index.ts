import { ethers } from "ethers";
import { Monopoly_Bank_ABI } from "../Contract_ABI_Address/Monopoly_Bank_ABI";
import { Monopoly_Bank_Address } from "../Contract_ABI_Address/Monopoly_Bank_Address";
import { Monopoly_Contract_ABI } from "../Contract_ABI_Address/Monopoly_Property_ABI";
import { Monopoly_Contract_Address } from "../Contract_ABI_Address/Monopoly_Property_Address";
import { Monopoly_Token_ABI } from "../Contract_ABI_Address/Monopoly_Token_ABI";
import { Monopoly_Token_Address } from "../Contract_ABI_Address/Monopoly_Token_Address";

// Access the private key from environment variables
const PRIVATE_KEY = import.meta.env.VITE_PRIVATE_KEY;

const connectToContract = async (CONTRACT_ADDRESS: string, CONTRACT_ABI: any) => {
  try {
    // Connect to Ethereum provider and signer
    const provider = new ethers.BrowserProvider(window.ethereum);
    const signer = await provider.getSigner();
    
    // Create contract instance
    const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer);
    
    console.log("Connected to contract:", contract);
    return contract;
  } catch (error) {
    console.error("Error connecting to contract:", error);
    throw error;
  }
};

// 1. Bank to Player (MonopolyBank)
export const transferToPlayer = async (player: string, amount: ethers.BigNumber) => {
  const contract = await connectToContract(Monopoly_Bank_Address, Monopoly_Bank_ABI);
  const tx = await contract.transferToPlayer(player, amount);
  await tx.wait();
  return tx;
};

// 2. Player to Bank (MonopolyBank)
export const transferToBank = async (player: string, amount: ethers.BigNumber) => {
  const contract = await connectToContract(Monopoly_Bank_Address, Monopoly_Bank_ABI);
  const tx = await contract.transferToBank(player, amount);
  await tx.wait();
  return tx;
};

// 3. Player to Player (MonopolyBank)
export const playerToPlayer = async (from: string, to: string, amount: ethers.BigNumber) => {
  const contract = await connectToContract(Monopoly_Bank_Address, Monopoly_Bank_ABI);
  const tx = await contract.playerToPlayer(from, to, amount);
  await tx.wait();
  return tx;
};

// 4. Changing Ownership of Property (MonopolyProperty)
export const transferProperty = async (propertyId: number, newOwner: string) => {
  const contract = await connectToContract(Monopoly_Contract_Address, Monopoly_Contract_ABI);
  const tx = await contract.transferProperty(propertyId, newOwner);
  await tx.wait();
  return tx;
};

// 5. Creating Monopoly Tokens (MonopolyToken)
export const mintMonopolyTokens = async (to: string, amount: ethers.BigNumber) => {
  const contract = await connectToContract(Monopoly_Token_Address, Monopoly_Token_ABI);
  const tx = await contract.mint(to, amount);
  await tx.wait();
  return tx;
};

// 6. Create Bank for Each Game Board (MonopolyToken)
export const createGameBoard = async (
  boardId: number,
  initialBankSupply: ethers.BigNumber,
  players: string[],
  playerInitialFunds: ethers.BigNumber
) => {
  const contract = await connectToContract(Monopoly_Token_Address, Monopoly_Token_ABI);
  const tx = await contract.createGameBoard(boardId, initialBankSupply, players, playerInitialFunds);
  await tx.wait();
  return tx;
};

// 7. Initial Supply for Each Game Board and Players (MonopolyToken)
export const initializeGameBoard = async (
  boardId: number,
  initialBankSupply: ethers.BigNumber,
  players: string[],
  playerInitialFunds: ethers.BigNumber
) => {
  return createGameBoard(boardId, initialBankSupply, players, playerInitialFunds);
};

// 8. Give Properties at Initial Stage (MonopolyProperty)
export const registerProperty = async (boardId: number, price: number, rent: number) => {
  const contract = await connectToContract(Monopoly_Contract_Address, Monopoly_Contract_ABI);
  const tx = await contract.registerProperty(boardId, price, rent);
  await tx.wait();
  return tx;
};

// 9. Get Properties of the Player (MonopolyProperty)
export const getPlayerProperties = async (boardId: number, ownerAddress: string) => {
  const contract = await connectToContract(Monopoly_Contract_Address, Monopoly_Contract_ABI);
  const properties = [];
  
  // Loop through all properties and check ownership
  for (let i = 0; i < 40; i++) {
    try {
      const property = await contract.properties(i);
      if (property.boardId === boardId && property.owner.toLowerCase() === ownerAddress.toLowerCase()) {
        properties.push(property);
      }
    } catch (error) {
      console.error(`Error fetching property with ID ${i}:`, error);
    }
  }
  
  return properties;
};



// 2. bank to player
// 3. player to bank
// 4. player to player
// 5. changing ownership of a property (NFT)
// 6. creating monopoly tokens(ERC-20)
// 7. create bank for each game board
// 8. initial supply for each game board bank and to the players with MNP tokens
// 9. give the properties at initial stage like when creating a game board
// 10. get properties of the player(board id , owner address)