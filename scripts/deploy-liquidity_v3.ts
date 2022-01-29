/* eslint-disable prettier/prettier */
// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  const nonfungiblePositionManager = "0xC36442b4a4522E871399CD717aBDD847Ab11FE88";
  const factory = "0x1F98431c8aD98523631AE4a59f267346ea31F984";
  const weth9 = "0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889";
  const Liquidity = await ethers.getContractFactory("UniswapLiquidity");

  const liquidity = await Liquidity.deploy(
    nonfungiblePositionManager
  );
  await liquidity.deployed();
  console.log(liquidity.address);

  // await liquidity.mintNewPosition();

  // await testApprove(liquidity.address);
  
}

// async function testApprove(address: string) {
//   const Liquidity = await ethers.getContractFactory("UniswapLiquidity");
//   const liquidity = await Liquidity.attach(address);
//   await liquidity.mintNewPosition();
//   // await liquidity.safeTransfer();
// }

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
