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

    await singleSwap.swapExactInputSingle(50000);
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
