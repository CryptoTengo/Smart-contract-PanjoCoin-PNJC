# 🐕 PanjoCoin (PNJC) Tokenomics

PanjoCoin (PNJC) is a fixed-supply ERC-20 token deployed on the Polygon network. The tokenomics structure is fully defined on-chain and designed for transparency, traceability, and decentralized governance.

All allocations are permanently assigned to dedicated wallets or smart contracts at deployment. No hidden minting, inflation, or off-chain issuance mechanisms exist.

---

## 🌐 Core Token Parameters

- Token Name: PanjoCoin
- Symbol: PNJC
- Network: Polygon
- Standard: ERC-20
- Decimals: 18
- Total Supply: **1,000,000,000,000 PNJC (1 Trillion)**
- Mint Function: **Disabled (permanent fixed supply)**
- Ownership Model: Multisig / DAO Controlled (as specified per wallet category)

---

## 📊 Official Allocation Table

All allocations are enforced through direct wallet assignment at genesis.

| Wallet Category            | Allocation | Amount (PNJC)       | Wallet Address | Primary Function |
|---------------------------|-----------|---------------------|----------------|-----------------|
| 👑 Main Wallet            | —         | —                   | 0x35520a1B48dB3c9c45343cc05A23a970EEa740c6 | Primary ecosystem deployment and coordination |
| 💧 Liquidity Reserve      | 50%       | 500,000,000,000     | 0xf55B994FDD7019d8E99c632c76A6e0AdE765988A | DEX liquidity provisioning (Uniswap / Quickswap) |
| 🏦 Project Treasury       | 12%       | 120,000,000,000     | 0xD539a54f54e9B174F831D9Da6b48ac15441fC581 | Infrastructure, development, operations |
| 🏛 DAO Treasury           | 10%       | 100,000,000,000     | 0xD5e2DD65BA4984565b53EFdcec6A9D2F494b5FE2 | Community governance-controlled treasury |
| 👨‍💻 Core Team Reserve     | 10%       | 100,000,000,000     | 0xdEBACbF7f51C3865dc2034ED676D3d344954f9FE | Long-term contributor incentives (vested) |
| 🌍 Community & Growth     | 8%        | 80,000,000,000      | 0x54D3beB9e0F473803cC7a972Db2C17f005a2D089 | Ecosystem expansion & community rewards |
| 👤 Founder Allocation     | 5%        | 50,000,000,000      | 0xF48840486697AE3c15D38E30e45cECB9897CfA74 | Founder long-term alignment (vested/locked) |
| ❤️ Charity Reserve        | 5%        | 50,000,000,000      | 0xa22E471BF4e405c92bDD074792d8d36923e31055 | Social impact and charitable initiatives |

---

## 🔐 Allocation Enforcement Model

All allocations are enforced using deterministic on-chain wallet assignments.

Key properties:

- ✔ No reallocation after deployment
- ✔ No hidden minting capability
- ✔ No off-chain issuance
- ✔ All balances are publicly verifiable on-chain
- ✔ Treasury wallets are controlled via multisignature or DAO governance
- ✔ Liquidity reserve is strictly designated for DEX provisioning only

---

## 💧 Liquidity Design (DEX Structure)

The Liquidity Reserve (50%) is used exclusively for:

- Initial DEX liquidity provisioning
- Uniswap (Polygon) pool creation
- Quickswap pool creation
- Market stability during early trading phases

### LP Security Requirements:
- LP tokens will be locked using a third-party locker (e.g. Unicrypt / Team Finance)
- OR permanently burned after verification
- Lock duration: long-term / irreversible (recommended)

---

## 🏛 Governance Structure

- DAO Treasury is governed by community voting mechanisms (future phase)
- Treasury wallet is multisignature controlled until DAO activation
- No single private key can move treasury funds independently

---

## 👨‍💻 Team & Founder Allocation

- Core Team Reserve and Founder Allocation are subject to vesting schedules
- Designed for long-term alignment with ecosystem growth
- Prevents early-stage token dumping pressure

(Exact vesting schedules are defined in Vesting Smart Contract documentation)

---

## 🌍 Community & Charity Model

Community & Growth allocation is used for:

- Incentive programs
- Airdrops
- Ecosystem expansion
- Partnerships and marketing campaigns

Charity Reserve is allocated for:

- Verified social impact initiatives
- Transparent on-chain donations
- Community-approved charitable programs

---

## 🔄 Supply Model

- Total Supply is fixed at deployment
- No inflationary mechanisms exist
- No token rebasing
- No hidden minting functions
- All tokens are pre-allocated at genesis

---

## ⚠️ Risk Disclosure

PNJC is a decentralized experimental digital asset.

Users acknowledge:

- Cryptocurrency markets are highly volatile
- No guarantee of financial return exists
- Smart contract risk is inherent in all blockchain systems
- Users are fully responsible for their own decisions

---

## 📌 Summary

This tokenomics model is designed to meet:
- DEX listing requirements (Uniswap / Quickswap)
- On-chain transparency standards
- Audit-style documentation expectations (CertiK-level structure)
- Long-term ecosystem sustainability

All allocations are permanently verifiable on-chain.
