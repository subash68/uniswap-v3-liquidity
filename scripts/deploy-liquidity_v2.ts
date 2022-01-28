// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  const amountToPlay = 1000000;
const Liquidity = await ethers.getContractFactory("LiquiditySetup");
//   let liquidity = await Liquidity.deploy();

//   await liquidity.deployed();

//   // const Liq = await ethers.getContractFactory("LiquiditySetup");
//   liquidity = await Liquidity.attach(liquidity.address);
    
    const liquidity = await Liquidity.attach("0x0c7342ed4c209ac7fa872c8524a20c33744251e7");

  // get approval here
  const Token = await ethers.getContractFactory("Token");
  const dai = await Token.attach("0x6d5582c29d9Bd9E89ed8482786675b7348F33a1a");

  // approve the liquidity contract to spen
  await dai.approve(liquidity.address, amountToPlay);
  // send token to contract
  await dai.transfer(liquidity.address, amountToPlay);

  // approve position manager
  await dai.approve("0xC36442b4a4522E871399CD717aBDD847Ab11FE88", amountToPlay);

  const usdc = await Token.attach("0x4c012686b47874D79F49b13d3a5CB2aDC37e56ba");
  await usdc.approve(liquidity.address, amountToPlay);
  await usdc.transfer(liquidity.address, amountToPlay);

  // approve position manager
  await usdc.approve(
    "0xC36442b4a4522E871399CD717aBDD847Ab11FE88",
    amountToPlay
  );

  await liquidity.mintNewPosition().then((response) => {
    console.log(response);
  });

  // await liquidity.mintNewPosition().then((response) => {
  //   console.log(response);
  // });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
