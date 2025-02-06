const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("MonopolyProperty", (m) => {
  const deployer = m.getAccount(0); // Assuming the first account is the deployer

  const MonopolyProperty = m.contract("MonopolyProperty", [deployer]);

  return { MonopolyProperty };
});
