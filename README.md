PanjoCoin (PNJC) Smart Contract
This repository contains the official, verified smart contract for PanjoCoin (PNJC) — a decentralized utility-meme token deployed on the Polygon (Mainnet).

Overview
PanjoCoin (PNJC) is an ERC-20 asset designed to bridge the gap between community-driven crypto initiatives and high-impact social responsibility. A core mission of the project is to support and scale Medical Clowning (ClownCare) programs in Tbilisi, Georgia.

The project specifically focuses on funding professional therapeutic clowning at the M. Iashvili Children's Central Hospital, providing emotional support for children in the Oncology-Hematology and Neurosurgery departments.

Tokenomics & Details
Token Name: PanjoCoin

Symbol: PNJC

Blockchain: Polygon (Mainnet)

Total Supply: 1,000,000,000,000 PNJC (Fixed)

Decimals: 18

Official Contract Address: 0x6ec7e9abad71082797fde2dc309e8e6810d27a1b

Technical Features
The PNJC contract is engineered for Security and Fairness, implementing several automated constraints to protect early holders:

1. Fair-Launch Protection (First 24 Hours)
To prevent market manipulation and "sniping" during the initial launch phase, the contract enforces the following rules for the first 24 hours:

Anti-Whale (Wallet Limit): No single wallet can hold more than 1.0% of the total supply.

Anti-Dump (Transaction Limit): Individual transactions are capped at 0.5% of the total supply.

Anti-Bot (Trade Cooldown): A 30-second latency period is enforced between transactions from the same address to mitigate high-frequency trading bots.

Note: These restrictions expire automatically 24 hours after deployment.

2. Zero-Admin Architecture
No Minting: The total supply is fixed. No additional tokens can ever be created.

No Owner Functions: The contract has no "Owner" or "Admin" roles, meaning no one can pause trading, blacklist addresses, or modify the logic once deployed. It is 100% decentralized.

Deployment Information
Compiler Version: Solidity 0.8.25

EVM Version: Cancun

Optimization: Enabled (200 runs)

Framework: Built using OpenZeppelin-inspired standardized ERC-20 logic.

Purpose & Impact
PanjoCoin aims to transform the "meme-token" narrative into a vehicle for social good:

Philanthropy: Direct support for pediatric social care in Tbilisi clinical centers.

Ecosystem: Integration with the upcoming ONE+ social/gaming platform.

Transparency: Fully verified source code on Polygonscan
.

License
This project is licensed under the MIT License.
