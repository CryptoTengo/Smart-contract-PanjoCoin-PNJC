# 🛡️ PanjoCoin (PNJC) — Security Model v1.0

## Institutional Threat Model & Attack Surface Specification

---

# 1. 📌 Security Overview

PanjoCoin (PNJC) is a modular DeFi protocol composed of:

* ERC-20 token (PNJC.sol)
* Staking system
* Vesting + cliff distribution
* Airdrop mechanism
* Liquidity router
* Multisig governance layer

This document defines the **threat model, attack surface, and trust assumptions** for the entire protocol.

---

# 2. 🧠 Threat Model (System-Wide)

## 2.1 Adversary Types

The system assumes the existence of the following adversaries:

| Adversary Type        | Description                                      |
| --------------------- | ------------------------------------------------ |
| External Attacker     | Attempts exploits via smart contract interaction |
| MEV Bots              | Front-running / sandwich attack actors           |
| Malicious Insider     | Compromised multisig signer or admin             |
| Liquidity Manipulator | Attempts to distort price via pool manipulation  |
| Bot Networks          | Attempt to exploit airdrop / staking rewards     |

---

## 2.2 Security Objectives

The protocol is designed to ensure:

* No unauthorized minting of PNJC
* No bypass of vesting schedules
* No unilateral admin control
* No unauthorized liquidity extraction
* No reward inflation beyond defined emission model

---

# 3. ⚔️ Attack Surface Map

## 3.1 Contract-Level Attack Surface

```
PNJC Token
 ├── Mint/Burn logic risk (if enabled)
 ├── Transfer manipulation
 └── Ownership control risk

Staking Contract
 ├── Reward over-accrual risk
 ├── Reentrancy risk
 └── withdrawal manipulation

Vesting Contract
 ├── early unlock attempts
 ├── cliff bypass risk
 └── schedule manipulation

Router Contract
 ├── MEV exposure
 ├── slippage manipulation
 ├── invalid route injection

Multisig
 ├── signer compromise
 ├── signature replay risk
 └── governance takeover risk

Airdrop Contract
 ├── Sybil attacks
 ├── bot farming
 └── claim duplication
```

---

## 3.2 System-Level Attack Surface

| Layer            | Risk                |
| ---------------- | ------------------- |
| Token Layer      | Supply manipulation |
| Liquidity Layer  | Price distortion    |
| Governance Layer | Admin takeover      |
| Reward Layer     | Inflation attacks   |
| External DEX     | MEV exploitation    |

---

# 4. 💥 Exploit Scenarios

## 4.1 MEV Attack Scenario (Router Layer)

### Scenario:

Attacker monitors pending transactions and:

* Front-runs swap through PNJC_Free_Router
* Executes sandwich attack
* Extracts value via slippage difference

### Mitigation:

* Slippage limits enforced
* Deadline-based execution
* Route validation checks

---

## 4.2 Admin Abuse Scenario (Governance Layer)

### Scenario:

Compromised multisig majority:

* changes router logic
* modifies staking rewards
* redirects liquidity flows

### Mitigation:

* N-of-M multisig requirement
* optional timelock before execution
* signer distribution decentralization

---

## 4.3 Liquidity Drain Attack

### Scenario:

Attacker exploits:

* low liquidity pool depth
* high volatility window
* large swap execution

Result:

* severe price impact
* arbitrage extraction
* LP imbalance

### Mitigation:

* minimum liquidity thresholds
* slippage protection
* controlled router routing logic

---

## 4.4 Airdrop Sybil Attack

### Scenario:

Attacker creates multiple wallets to:

* farm airdrop rewards
* bypass eligibility rules
* drain allocation pool

### Mitigation:

* per-wallet limits
* optional Merkle tree distribution
* time-based claim restrictions

---

## 4.5 Vesting Bypass Attempt

### Scenario:

Attacker attempts:

* direct contract call bypassing cliff
* internal state manipulation
* unauthorized transfer extraction

### Mitigation:

* strict time-lock enforcement
* immutable vesting schedule logic
* no admin override on locked tokens

---

# 5. 🧾 Trust Assumptions Model

## 5.1 Smart Contract Assumptions

The system assumes:

* Ethereum/Polygon base layer is secure
* Solidity execution is deterministic
* No hidden backdoors in compiler/runtime
* External DEXs behave according to AMM logic

---

## 5.2 Governance Assumptions

* Multisig signers are independent entities
* No single signer controls majority alone
* Signers are not colluding maliciously
* Key management follows industry best practices

---

## 5.3 Economic Assumptions

* Market is partially efficient (arbitrage exists)
* Liquidity providers act rationally
* Token demand is not artificially manipulated at scale

---

## 5.4 External Dependency Assumptions

* Uniswap / Quickswap contracts are secure
* Oracle usage (if added) is reliable
* RPC nodes are not persistently malicious

---

# 6. 🔐 Security Design Principles

The protocol is built on the following principles:

### 6.1 Least Privilege

No contract has unnecessary administrative authority.

### 6.2 Separation of Concerns

Each contract handles a single domain (staking, vesting, routing).

### 6.3 Deterministic State Transitions

No hidden or probabilistic state changes.

### 6.4 Time-Bound Control

Critical token flows are governed by time-based vesting.

### 6.5 Multisig Governance

No single EOA controls critical system state.

---

# 7. 📊 Residual Risk Statement

Even with mitigations, the following risks remain:

* Smart contract vulnerabilities (unknown bugs)
* Market volatility risk
* MEV evolution beyond current mitigations
* Governance collusion risk
* Liquidity fragmentation risk

---

# 8. 🧠 Security Summary

PanjoCoin implements a **modular DeFi architecture with separated trust domains**, reducing systemic risk by isolating:

* token logic
* liquidity logic
* reward logic
* governance logic

---

# 🏁 Final Statement

> This system is designed to minimize single points of failure through modular architecture, deterministic tokenomics, and multisig governance, while acknowledging residual risks inherent in decentralized financial systems.
