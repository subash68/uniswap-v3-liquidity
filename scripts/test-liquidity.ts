/* eslint-disable prettier/prettier */
// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
	const Liq = await ethers.getContractFactory("LiquiditySetup");
	const liq = await Liq.attach("0xB9ce0823D48d33F2105ecd5Ce37d7ba80278514e");
	await liq.mintNewPositionWithApproval().then((response) => {
		console.log(response);
	});

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
