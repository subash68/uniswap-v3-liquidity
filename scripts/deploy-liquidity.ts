// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {

  const Liquidity = await ethers.getContractFactory("LiquiditySetup");
  const liquidity = await Liquidity.deploy(
    "0xC36442b4a4522E871399CD717aBDD847Ab11FE88"
  );

  await liquidity.deployed();

  console.log("Liquidity contract deployed to:", liquidity.address);

  // await liquidity.mintNewPosition().then((response) => {
  //   console.log(response);
  // });
  // await liquidity.mintNewPositionWithApproval().then((response) => {
  //   console.log(response);
  // });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
