/* eslint-disable prettier/prettier */
// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  const swapRouter = "0xE592427A0AEce92De3Edee1F18E0157C05861564";

  const SingleSwap = await ethers.getContractFactory("SingleSwap");

  const singleSwap = await SingleSwap.deploy(
    swapRouter,
  );
    
  await singleSwap.deployed();
  console.log(singleSwap.address)
  
  // get contract here
  const DAI = await ethers.getContractFactory("SimpleToken");
  const token = await DAI.attach("0x2C13E1ab78918b2B53612CA8c4CacF58c0CbdfC0");
  await token.approve(singleSwap.address, 50000000);
  const [sender] = await ethers.getSigners();
  await token.transferFrom(sender.address, singleSwap.address, 50000000)

  await singleSwap.swapExactInputSingle(50000000);
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
