# 🧠 PanjoCoin (PNJC) — Protocol Summary
## Single Source of Truth (SSoT)

---

## 1. Overview

PanjoCoin (PNJC) is a modular decentralized finance protocol deployed on Polygon.

This document serves as the **single entry point for understanding the entire system architecture, behavior, guarantees, and dependencies**.

It consolidates all protocol logic into one unified model for auditors, developers, and external integrators.

---

## 2. System Identity

The PNJC protocol is composed of five core subsystems:

1. Token Layer (PNJC ERC-20 core asset)
2. Liquidity Layer (DEX AMM markets)
3. Staking Layer (reward mechanism)
4. Vesting Layer (time-locked distribution)
5. Governance Layer (multisig → DAO evolution)

👉 The Token Layer is the root of all system interactions.

---

## 3. System Core Definition

### 🔑 CORE COMPONENT:

**PNJC Token Contract (ERC-20)**

This is the immutable foundation of the protocol.

It defines:

- Total supply (fixed)
- Ownership transfers
- Base asset for all interactions
- Input token for staking and liquidity

✔ No system functionality exists without this contract.

---

## 4. System Architecture Flow

### End-to-End Execution Flow:
