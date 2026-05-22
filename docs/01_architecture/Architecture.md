# 🧠 PanjoCoin (PNJC) — System Architecture

---

## 1. Overview

The PanjoCoin (PNJC) architecture defines the full system design of the protocol as a modular, on-chain decentralized ecosystem deployed on the Polygon network.

This document serves as the **single source of truth** for how all protocol components interact.

The system is designed with strict separation between token logic, liquidity, governance, and vesting layers.

---

## 2. High-Level System Design

The PNJC protocol consists of five core layers:

1. Token Layer (ERC-20 Core)
2. Liquidity Layer (DEX Markets)
3. Staking Layer (Rewards System)
4. Vesting Layer (Time-locked Distribution)
5. Governance Layer (Multisig + Future DAO)

Each layer operates independently but interacts through predefined smart contract interfaces.

---

## 3. System Flow (Core Interaction Model)

The end-to-end flow of the PNJC ecosystem is as follows:

```text
Users
  ↓
ERC-20 Token (PNJC.sol)
  ↓
┌──────────────────────────────┐
│                              │
│   Staking System             │
│   Vesting System             │
│   Liquidity Pools (DEX)      │
│                              │
└──────────────────────────────┘
  ↓
Rewards / Unlocks / Trading
  ↓
Treasury (Multisig)
  ↓
DAO Governance (Future Phase)
