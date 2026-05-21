# 📌 Assumptions Model — PanjoCoin (PNJC)
## System Truth & Dependency Foundations Layer

---

## 1. Overview

This document defines the **explicit assumptions under which the PanjoCoin (PNJC) protocol is designed to operate correctly**.

It separates:

- what the system guarantees internally (hard truth)
- what the system assumes externally (dependency truth)

This is the final missing layer for full protocol completeness.

---

## 2. Core Principle

> The PNJC protocol is only as secure as its assumptions about external systems.

All internal guarantees depend on these assumptions holding true.

---

## 3. INTERNAL ASSUMPTIONS (SYSTEM GUARANTEES)

These are **hard invariants enforced by smart contracts**:

### 🪙 Token Model Assumptions
- Total supply is fixed at deployment
- No minting functions exist under any condition
- Token transfers follow ERC-20 standard logic

---

### ⏳ Vesting Assumptions
- Vesting schedules are deterministic
- Cliff + linear unlock logic is time-based only
- No external override can modify vesting state

---

### ⚙️ Staking Assumptions
- Reward calculations are deterministic
- Staking state is isolated per user
- No external contract can alter reward formulas

---

### 🏛 Governance Assumptions
- Multisig signatures are required for execution (Phase 1)
- DAO governance is rule-based and on-chain
- Treasury actions follow predefined permission rules

---

### 🔐 Invariants Assumptions
- System invariants are always enforced at contract level
- Violations are impossible without contract failure

---

## 4. EXTERNAL ASSUMPTIONS (OUTSIDE PROTOCOL CONTROL)

These are **critical dependencies on external systems**:

---

### 🌐 Blockchain Layer Assumptions
- Polygon network remains operational
- Block finality is reliable
- Chain does not experience catastrophic failure
- Gas pricing remains within functional bounds

---

### 💧 DEX / Market Assumptions
- Uniswap / Quickswap AMM math is correct
- Liquidity pools remain functional
- Router contracts behave as documented
- No protocol-level censorship of swaps

---

### 👥 Market Behavior Assumptions
- Market participants act independently
- Arbitrage mechanisms function correctly
- MEV exists and cannot be fully eliminated
- Liquidity providers behave rationally under incentives

---

### 🔐 Multisig Assumptions
- Signers act independently and honestly (Phase 1–2)
- No full compromise of signing set occurs
- Key management is maintained securely

---

### ⚙️ Infrastructure Assumptions
- RPC nodes respond correctly
- Frontend and indexers reflect correct state
- No widespread data inconsistency across nodes

---

## 5. INVALID ASSUMPTIONS (EXPLICITLY REJECTED)

The protocol explicitly does NOT assume:

- stable token price
- guaranteed profitability
- absence of market manipulation
- absence of MEV
- perfect liquidity conditions
- zero user error

---

## 6. DEPENDENCY HIERARCHY
