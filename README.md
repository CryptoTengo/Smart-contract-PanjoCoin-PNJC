# 🐾 PanjoCoin (PNJC)

> **The meme token with real charitable utility.**  
> A decentralized Web3 ecosystem built on Polygon, uniting the crypto community through transparent charitable giving and advanced DeFi mechanics.

---

## 1. 📄 Project Overview

**PanjoCoin (PNJC)** is a utility-driven meme token designed to fund medical clowning programs for children battling cancer and to support pediatric healthcare systems. Leveraging the high-speed, low-fee architecture of the Polygon network, the project provides users with a transparent on-chain charity contribution mechanism, a low-gas staking ecosystem, and a secure vesting schedule to ensure long-term market stability.

---

## 2. 🌐 Essential Links

*   **🌐 Official Website:** [panjocoin.com](https://cryptotengo.github.io/PanjoCoin-Docs/) *(Documentation placeholder)*
*   **📘 Whitepaper & Documentation:** [Ecosystem GitBook](https://github.com/CryptoTengo/PanjoCoin-Docs)
*   **📊 Smart Contract Audit:** *In Progress*
*   **🔒 Token Smart Contract:** [Polygonscan Contract Link](https://polygonscan.com/address/0x781C0d15347Cb0B94C42C65c7a67E70371205De5)
*   **📈 Charts & Analytics:** [DEX Screener](https://dexscreener.com)
*   **📢 Media Channels:** [Medium Blog](https://medium.com/@cryptotengo) | [YouTube Channel](https://www.youtube.com/@CryptoTengo)
*   **💬 Social Media:** [X (formerly Twitter)](https://x.com/CryptoTengo) | [Instagram](https://www.instagram.com/crypto.tengo/) | [Facebook](https://www.facebook.com/cryptotengo) | [TikTok](https://www.tiktok.com/@cryptotengo)
*   **👥 Community Hubs:** [Discord Server](https://discord.com/channels/1337364200254738454/1337364201588654093) | [Reddit Community](https://www.reddit.com/user/cryptotengo/)

---

## 3. ⚙️ Key Technical Features

*   **Deflationary Token Model:** Hard-capped total supply with absolutely no minting capabilities.
*   **Gasless Approvals (ERC-2612 Permit):** Users can interact with the ecosystem applications via off-chain signatures without spending native MATIC/POL on initial token approvals.
*   **Transparent Charitable Utility:** All funds allocated to charity are tracked strictly on-chain, ensuring tamper-proof, real-time public auditability.
*   **Multi-Signature Security:** Treasury reserves and critical parameter updates are governed via a secure M-of-N Multisig contract.
*   **Locked Liquidity:** Programmatic liquidity pool locking mechanisms are implemented to prevent rug-pull vectors and guarantee market integrity.

---

## 4. 📊 Token Information

| Parameter | Value |
| :--- | :--- |
| **Token Name** | PanjoCoin |
| **Symbol** | PNJC |
| **Network** | Polygon Mainnet |
| **Standard** | ERC-20 / ERC-2612 (Permit) |
| **Total Supply** | 1,000,000,000 PNJC *(Fixed)* |
| **Decimals** | 18 |
| **Contract Address** | `0x781C0d15347Cb0B94C42C65c7a67E70371205De5` |

---

## 🪙 5. Tokenomics

The total supply allocation is programmatically enforced by deployment architectures and smart contract parameters:

| Allocation | Share (%) | Purpose / Utility |
| :--- | :--- | :--- |
| **Liquidity Pool** | 50% | Initial liquidity provision on DEX platforms (QuickSwap/Uniswap) |
| **Staking Rewards** | 15% | Yield distribution for long-term holders via `PNJC_Staking.sol` |
| **Charity Fund** | 10% | Dedicated on-chain allocation for medical clowning foundations |
| **Marketing & Ecosystem** | 10% | Brand growth, CEX listings, and global influencer campaigns |
| **Treasury Reserve** | 10% | Emergency and operational buffer managed by `PNJC_Multisig.sol` |
| **Team & Advisors** | 5% | Locked inside `PNJC_Vesting+Cliff.sol` with a linear release schedule |

---

## 🛠 6. Smart Contract Overview

The core ecosystem infrastructure consists of 6 modular smart contracts located in the `/Smart-Contracts` directory:

1.  **`PNJC.sol`**: Core ERC-20 token contract. Features a strictly `Fixed supply` with no hidden mint functions and no address blacklisting, fully integrating the ERC-2612 Permit extension.
2.  **`PNJC_Staking.sol`**: Yield-bearing lock contract. Enables holders to commit PNJC into time-locked epochs with structural anti-drain protection.
3.  **`PNJC_Vesting+Cliff.sol`**: Token release management contract. Mitigates early market dump vectors by locking team and seed allocations behind a strict `Cliff` (lockup period), followed by gradual linear release intervals.
4.  **`PNJC_Multisig.sol`**: Decentralized co-signature treasury wallet. Requires a cryptographic consensus of N-out-of-M trusted admin signatures to execute any treasury movements.
5.  **`PNJC_Airdrop.sol`**: Gas-optimized batch transfer utility designed for high-efficiency token distribution to community event winners.
6.  **`PNJC_Free_Router.sol`**: Specialized low-fee internal transaction router optimizing multi-calls and cross-app calls within the ecosystem.

---

## 🔒 7. Security & Transparency

*   **Audit Status:** The codebase is fully structured and prepared for external, third-party independent security audits.
*   **Anti-Manipulation Guarantee:** The absolute absence of minting capabilities (`no-mint`) or central frozen-state lists (`no-blacklist`) guarantees absolute decentralized ownership.
*   **Public Accountability:** All charity outlays are visible in real-time on-chain via Polygonscan to eliminate opaque corporate overhead structures.

---

## 🗺️ 8. Roadmap

### Phase 1: Foundations
* [x] Deployment of the PNJC token on Polygon Mainnet.
* [x] Public open-source code migration to GitHub.
* [ ] Official website release with native Web3 wallet integration.
* [ ] Community onboarding across Discord, Telegram, and X.

### Phase 2: Ecosystem Launch & Liquidity
* [ ] Verification of all peripheral contracts (Staking, Vesting) on Polygonscan.
* [ ] Automated liquidity pool creation and locking on QuickSwap.
* [ ] Staking portal deployment for active public participation.
* [ ] Execution of the inaugural verifiable charity transaction to medical clowning initiatives.

### Phase 3: Global Scale
* [ ] Tracking verification on CoinMarketCap and CoinGecko.
* [ ] Launch of charitable utility NFT collections.
* [ ] Transition of critical parameter controls to a community-led DAO governance model.
* [ ] Expansion into Tier-1/Tier-2 Centralized Exchanges (CEX).

---

## 🛒 9. How to Buy PanjoCoin (PNJC)

1. Install an industry-standard Web3 wallet (e.g., **MetaMask** or **Trust Wallet**).
2. Configure or select the **Polygon POS** network within your interface.
3. Fund your wallet address with **POL / MATIC** (to pay network gas fees) and **USDT / USDC** (for trade execution).
4. Connect to a supported decentralized exchange (e.g., **QuickSwap** or **Uniswap**).
5. Import the PNJC token manually using the verified contract address: `0x781C0d15347Cb0B94C42C65c7a67E70371205De5`.
6. Set your slippage preferences, execute the Swap, and sign the transaction in your wallet.

---

## 💻 10. Development & Local Setup

Developers and auditors can compile and simulate the ecosystem contracts locally:

```bash
# Clone the repository
git clone [https://github.com/CryptoTengo/PanjoCoin-Docs.git](https://github.com/CryptoTengo/PanjoCoin-Docs.git)
cd PanjoCoin-Docs

# Initialize the environment and install Hardhat along with OpenZeppelin security primitives
npm init -y
npm install --save-dev hardhat @openzeppelin/contracts dotenv

# Compile smart contracts
npx hardhat compile
