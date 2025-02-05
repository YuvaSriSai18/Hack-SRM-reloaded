import { ethers } from 'ethers';
import React, { useState } from 'react';


export default function ConnectWallet() {
  const [walletAddress, setWalletAddress] = useState("");

  async function connectWallets() {
    if (typeof window.ethereum !== 'undefined') {
      await connectWallet();

      const provider = new ethers.BrowserProvider(window.ethereum);
    }
  }

  const connectWallet = async () => {
    if (window.ethereum) {
      console.log("Ethereum is available");

      try {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        if (accounts.length > 0) {
          setWalletAddress(accounts[0]);
        }
      } catch (error) {
        console.error("Error connecting to wallet:", error);
      }
    } else {
      console.log("Ethereum is not available. Please install MetaMask.");
    }
  };

  return (
    <>
      <button onClick={connectWallet}>Connect to Wallet</button>
      <h3>{walletAddress ? `Connected: ${walletAddress}` : "Not Connected"}</h3>
    </>
  );
}
