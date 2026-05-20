// scripts/deploy-airdrop.js
const { ethers } = require("hardhat");

async function main() {
    const TOKEN_ADDRESS = "0x781C0d15347Cb0B94C42C65c7a67E70371205De5"; // PNJC token
    const VESTING_START = Math.floor(Date.now() / 1000) + 7 * 24 * 3600; // 7 days from now
    const VESTING_DURATION = 180 * 24 * 3600; // 180 days (6 months)
    const TGE_BPS = 2000; // 20% upfront, 80% linear vesting

    console.log("Deploying PNJC_Airdrop...");
    console.log(`Token: ${TOKEN_ADDRESS}`);
    console.log(`Vesting Start: ${new Date(VESTING_START * 1000).toISOString()}`);
    console.log(`Vesting Duration: ${VESTING_DURATION / 86400} days`);
    console.log(`TGE: ${TGE_BPS / 100}%`);

    const Airdrop = await ethers.getContractFactory("PNJC_Airdrop");
    const airdrop = await Airdrop.deploy(
        TOKEN_ADDRESS,
        VESTING_START,
        VESTING_DURATION,
        TGE_BPS
    );

    await airdrop.waitForDeployment();
    console.log(`PNJC_Airdrop deployed to: ${await airdrop.getAddress()}`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
