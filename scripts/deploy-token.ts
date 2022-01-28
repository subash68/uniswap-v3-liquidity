// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  const Token = await ethers.getContractFactory("Token");
  const token1 = await Token.deploy("sDAI Token", "sDAI", 1, 1e9);
  const token2 = await Token.deploy("sUSDC Token", "sUSDC", 1, 1e9);

  await token1.deployed();
  await token2.deployed();

  console.log("test token 1 deployed to:", token1.address);
  console.log("test token 2 deployed to:", token2.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
