import { ethers } from "ethers";
import { useState } from "react";

import { Monopoly_Contract_Address } from "../Contract_ABI_Address/Monopoly_Property_Address";
import { Monopoly_Contract_ABI } from "../Contract_ABI_Address/Monopoly_Property_ABI";
// Replace with your contract address
const CONTRACT_ADDRESS = Monopoly_Contract_Address;

// Replace with your contract ABI
const CONTRACT_ABI = Monopoly_Contract_ABI

export default function ConnectWallet() {
  const [walletAddress, setWalletAddress] = useState("");
  const [isConnected, setIsConnected] = useState(false);

  // Connect Wallet
  const connectWallet = async () => {
    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
        setWalletAddress(accounts[0]);
        connectToContract();
      } catch (error) {
        console.error("Error connecting to wallet:", error);
      }
    } else {
      alert("Please install MetaMask!");
    }
  };

  // Connect to Smart Contract
  const connectToContract = async () => {
    try {
      const provider = new ethers.BrowserProvider(window.ethereum);
      const signer = await provider.getSigner();
      const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer);
      
      console.log("Connected to contract:", contract);
      setIsConnected(true);
    } catch (error) {
      console.error("Error connecting to contract:", error);
    }
  };

  return (
    <div>
      <h2>Connect Wallet & Smart Contract</h2>
      {walletAddress ? (
        <>
          <p><strong>Connected Wallet:</strong> {walletAddress}</p>
          <p><strong>Contract Status:</strong> {isConnected ? "Connected ✅" : "Not Connected ❌"}</p>
        </>
      ) : (
        <button onClick={connectWallet}>Connect Wallet</button>
      )}
    </div>
  );
}
