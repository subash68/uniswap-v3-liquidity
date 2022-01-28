/* eslint-disable prettier/prettier */
// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
	// const Liq = await ethers.getContractFactory("LiquiditySetup");
	// const liq = await Liq.attach("0x9Dec84F5b9F1897B4ef49CF4cEDe87A935B77697");

	// get approval here
	const Token = await ethers.getContractFactory("Token");
	const dai = await Token.attach("0x6d5582c29d9Bd9E89ed8482786675b7348F33a1a");

	// approve the liquidity contract to spend
	await dai.approve("0x9Dec84F5b9F1897B4ef49CF4cEDe87A935B77697", 1000000);
	// send token to contract
	await dai.transfer("0x9Dec84F5b9F1897B4ef49CF4cEDe87A935B77697", 1000000);

	const usdc = await Token.attach("0x4c012686b47874D79F49b13d3a5CB2aDC37e56ba");
	await usdc.approve("0x9Dec84F5b9F1897B4ef49CF4cEDe87A935B77697", 1000000);
	await usdc.transfer("0x9Dec84F5b9F1897B4ef49CF4cEDe87A935B77697", 1000000);

	// await liq.safeTransferDAI().then((response) => {
	// 	console.log(response);
	// });
	// await liq.safeTransferUSDC().then((response) => {
	// 	console.log(response);
	// });

	// await liq.mintNewPosition().then((response) => {
	// 	console.log(response);
	// });
	
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
