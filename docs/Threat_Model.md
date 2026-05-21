
# 🛡 Threat Model — PanjoCoin (PNJC)

---

## 1. Overview

This document defines the **threat landscape and attack surface model** of the PanjoCoin (PNJC) protocol.

It describes how the system can be attacked, under what conditions, and what assumptions must hold for safe operation.

This model complements:
- Risk Disclosure (what can go wrong)
- System Invariants (what must remain true)
- Security Model (how protection is designed)

---

## 2. Attack Surface Summary

The PNJC protocol has four primary attack surfaces:

1. Smart Contract Layer
2. Liquidity / Market Layer
3. Governance Layer
4. External Infrastructure Layer (DEX + blockchain)

Each layer has distinct adversarial models.

---

## 3. Smart Contract Attack Vectors

### 3.1 Token Contract Exploits

**Target: PNJC ERC-20 core**

Potential risks:
- Unauthorized minting (MITIGATED: no mint function exists)
- Supply manipulation (MITIGATED: fixed supply design)
- Transfer logic edge cases
- Approval race conditions (ERC-20 standard risk)

✔ Residual risk: low (standard ERC-20 surface)

---

### 3.2 Staking Contract Exploits

**Target: PNJC_Staking.sol**

Potential risks:
- Reward inflation bugs
- Incorrect reward calculation
- Re-entrancy during claim flows
- Denial-of-service via gas exhaustion patterns

✔ Mitigation:
- deterministic reward formulas
- non-reentrant design patterns (expected)
- isolated staking state machine

---

### 3.3 Vesting Contract Exploits

**Target: PNJC_Vesting+Cliff.sol**

Potential risks:
- premature unlock attempts
- time manipulation edge cases (block timestamp dependency)
- incorrect allocation calculations

✔ Mitigation:
- strict time-based unlock logic
- no admin override functions
- linear deterministic vesting schedule

---

## 4. Liquidity & Market Attack Vectors

### 4.1 MEV Attacks

**Target: DEX trading pools**

Attack types:
- front-running swaps
- sandwich attacks
- liquidation arbitrage loops
- block reordering exploitation

✔ Nature:
External to protocol (AMM-level risk)

✔ Mitigation:
- cannot be eliminated at protocol level
- partially mitigated by:
  - deeper liquidity
  - fair launch distribution
  - no internal price manipulation

---

### 4.2 Liquidity Manipulation

Attack types:
- flash loan price distortion
- temporary pool imbalance
- spoof volume trading

✔ Mitigation:
- AMM-based pricing only
- no oracle dependency
- LP lock/burn reduces centralized manipulation risk

---

## 5. Governance Attack Vectors

### 5.1 Multisig Compromise

**Target: PNJC_Multisig.sol**

Attack types:
- signer key compromise
- collusion among signers
- social engineering attacks

✔ Mitigation:
- distributed signer architecture
- M-of-N threshold requirements
- no direct control over token economics

---

### 5.2 Governance Capture (DAO Phase)

Future risks:
- token-weighted governance takeover
- whale dominance in voting
- proposal spam attacks

✔ Mitigation (design-level):
- phased DAO transition
- potential quorum thresholds
- governance delay mechanisms (future implementation)

---

## 6. Oracle / Price Manipulation Assumptions

### Critical Note:

PNJC does NOT rely on external oracles for core token logic.

Therefore:

- No price feed dependency in token contract
- No oracle manipulation risk for token transfers

### Residual exposure:
- external DeFi integrations may introduce oracle reliance

✔ Protocol-level risk: minimized

---

## 7. Smart Contract Exploit Surface (Global)

### Known general risks:

- ERC-20 standard edge cases
- gas limit constraints
- unexpected revert conditions
- interaction with unknown external contracts (staking integrations)

### Design mitigation:

- modular architecture separation
- no cross-module privileged access
- explicit trust boundaries defined in enforcement layer

---

## 8. External Infrastructure Threats

### 8.1 Blockchain-Level Risks

- Polygon network congestion
- chain reorgs (low probability)
- validator-level censorship

✔ Not controllable by protocol

---

### 8.2 DEX-Level Risks

- Uniswap / Quickswap smart contract risk
- liquidity pool integrity risk
- routing vulnerabilities in aggregators

✔ Fully external dependency

---

## 9. Composite Attack Scenarios

### Scenario A — Liquidity + Governance Attack

- attacker manipulates market price
- attempts governance influence
- fails to affect token supply due to invariants

✔ Impact: limited to market volatility only

---

### Scenario B — Multisig Compromise

- treasury control is partially at risk
- token contract remains unaffected
- liquidity remains unaffected (if locked)

✔ Impact radius: treasury only

---

## 10. Systemic Assumptions

The protocol assumes:

- Ethereum-compatible chain behaves correctly
- cryptographic primitives remain secure
- DEX AMM math is correct
- multisig signers act independently

---

## 11. Residual Risk Statement

Even with full mitigation:

- market manipulation remains possible (external)
- MEV cannot be eliminated
- governance capture is possible in extreme DAO concentration scenarios
- smart contract bugs remain theoretically possible

---

## 12. Final Statement

The PanjoCoin threat model demonstrates that:

- core token logic has minimal attack surface
- liquidity risks are externalized to AMM systems
- governance risks are structurally constrained
- no single exploit can compromise the entire protocol

This model confirms that PNJC operates under a **layered security and isolation architecture**, reducing systemic risk propagation.
