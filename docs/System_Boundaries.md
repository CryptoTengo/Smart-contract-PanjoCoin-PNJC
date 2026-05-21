# 🚧 System Boundaries — PanjoCoin (PNJC)
## Protocol Boundary Definition Layer

---

## 1. Overview

This document defines the **exact boundaries of the PanjoCoin (PNJC) protocol**.

It explicitly separates:

- what is inside the protocol (internal logic)
- what is outside the protocol (external systems)
- what is controlled vs not controlled

This prevents misinterpretation of system responsibility.

---

## 2. Core Principle

> The PNJC protocol defines rules for token behavior, NOT external market behavior.

---

## 3. WHAT IS INSIDE THE PROTOCOL (IN-SCOPE)

The following components are fully controlled by smart contracts:

### 🪙 Token Layer
- PNJC ERC-20 contract
- Fixed supply logic
- Transfer and balance state

### ⏳ Vesting Layer
- Cliff-based unlock logic
- Linear release schedules
- Allocation enforcement

### ⚙️ Staking Layer
- Reward calculation logic
- Token locking mechanisms
- Claim execution rules

### 🏛 Governance Layer (Phase 1–2)
- Multisig execution logic
- DAO proposal system (future)
- Treasury allocation rules

### 🔐 Invariants System
- Fixed supply enforcement
- No minting rules
- Locked liquidity rules (post-deployment)

---

## 4. WHAT IS OUTSIDE THE PROTOCOL (OUT-OF-SCOPE)

The following elements are explicitly NOT controlled by PNJC:

---

### 📉 Market & Pricing Behavior

- Token price formation
- Market volatility
- Price discovery dynamics
- External trading behavior

👉 These are fully determined by DEX AMMs and market participants.

---

### 💧 DEX Infrastructure

- Uniswap / Quickswap smart contracts
- Liquidity pool mechanics (external implementation)
- Router behavior
- Aggregator routing logic

👉 PNJC does NOT control or modify DEX logic.

---

### 🌐 Blockchain Layer

- Polygon network consensus
- Block finality
- Gas pricing
- Network congestion

👉 These are external system properties.

---

### 👥 Market Participants

- Traders
- Liquidity providers
- Arbitrage bots
- MEV actors

👉 These actors operate independently of the protocol.

---

## 5. GOVERNANCE BOUNDARIES

Governance CAN:

- allocate treasury funds
- manage ecosystem incentives
- control protocol-owned resources (within limits)

Governance CANNOT:

- mint new tokens
- change total supply
- modify vesting rules
- override liquidity locks
- influence market pricing

---

## 6. PRICE CONTROL EXCLUSION

The protocol explicitly guarantees:

> ❌ No mechanism exists to control, fix, or stabilize token price.

Price is determined solely by:

- AMM pool ratios
- market demand
- liquidity depth
- external trading activity

---

## 7. LIQUIDITY BOUNDARY RULE

After deployment:

- Liquidity exists ONLY in external DEX pools
- LP tokens are locked or burned
- Protocol has no withdrawal authority over liquidity

👉 Liquidity becomes external system state.

---

## 8. EXECUTION BOUNDARY MODEL

### Inside boundary:

- deterministic smart contract execution
- on-chain state transitions
- rule enforcement logic

### Outside boundary:

- human behavior
- market psychology
- external protocols
- network conditions

---

## 9. TRUST SEPARATION MODEL

| Layer | Trust Required |
|------|---------------|
| Token contract | Minimal |
| Vesting logic | None (deterministic) |
| Liquidity (DEX) | External trust |
| Governance (multisig) | Partial trust (Phase 1) |
| Blockchain | External trust |

---

## 10. FAILURE BOUNDARY ISOLATION

If external systems fail:

- Token contract remains functional
- Vesting continues
- Staking continues (if blockchain operational)
- Governance remains intact

If internal system fails:

- Impact is isolated per module
- No cross-layer collapse is assumed

---

## 11. SYSTEM GUARANTEE STATEMENT

The PNJC protocol guarantees only:

- deterministic execution of smart contracts
- enforcement of internal invariants
- rule-based asset behavior

It does NOT guarantee:

- market performance
- price stability
- liquidity depth
- user profit

---

## 12. FINAL STATEMENT

PanjoCoin (PNJC) is a **bounded decentralized protocol**, where:

- internal logic is strictly enforced on-chain
- external systems define market outcomes
- governance operates within constrained authority
- price and liquidity are explicitly externalized

This boundary definition ensures full clarity of responsibility and eliminates ambiguity in protocol scope.
