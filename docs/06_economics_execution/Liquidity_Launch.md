# 💧 Liquidity Launch Model — PanjoCoin (PNJC)

---

## 1. Overview

This document defines the **complete liquidity deployment and lifecycle model** for PanjoCoin (PNJC) on decentralized exchanges.

The liquidity system is designed to ensure:

- Transparent price discovery
- No centralized liquidity control
- Long-term market stability assumptions
- Immutable post-launch liquidity constraints

---

## 2. Supported DEX Infrastructure

PNJC will be initially launched on:

- Uniswap (Polygon deployment)
- Quickswap (Polygon deployment)

Liquidity pools will operate under Automated Market Maker (AMM) mechanics.

---

## 3. Liquidity Pair Structure

Initial trading pairs:

- PNJC / USDC
- PNJC / MATIC (optional secondary pair)

Pricing is determined exclusively by AMM curve dynamics.

No internal pricing logic exists within the protocol.

---

## 4. Liquidity Deployment Flow

### Step 1 — Token Deployment
- PNJC ERC-20 contract deployed on Polygon
- Supply is fixed and verified on-chain

---

### Step 2 — Pool Creation
- Liquidity pool created on selected DEX
- Pair established between PNJC and base asset

---

### Step 3 — Initial Liquidity Injection
- Initial liquidity provided by deployer wallet
- Ratio defines initial market price

---

### Step 4 — LP Token Handling

After liquidity provision:

- LP tokens are either:
  - sent to a time-lock contract OR
  - permanently burned

✔ This ensures deployer cannot withdraw liquidity

---

### Step 5 — Trading Activation
- Token becomes publicly tradable
- Market enters price discovery phase

---

## 5. Price Discovery Model

PNJC price is determined by:

- AMM pool ratio
- Buy/sell pressure
- Liquidity depth
- Market demand

No centralized price controls exist.

---

## 6. Liquidity Lock / Burn Invariant

### Guarantee:
Liquidity cannot be withdrawn by deployer or team.

### Enforcement:
- LP tokens locked in immutable contract OR
- Sent to burn address

✔ After execution, liquidity becomes non-recoverable.

---

## 7. Market Phases

### Phase 1 — Launch Phase
- Low liquidity
- High volatility
- Initial price discovery

---

### Phase 2 — Stabilization Phase
- Increased trading volume
- Arbitrage normalization
- Market equilibrium formation

---

### Phase 3 — Mature Liquidity Phase
- Deeper liquidity pools
- Reduced volatility
- Ecosystem integration

---

## 8. Risk Conditions

Liquidity system includes inherent risks:

- Slippage during early trading
- Volatility in price discovery phase
- Impermanent loss for liquidity providers
- Market manipulation attempts (external)

---

## 9. System Boundaries

The PNJC protocol DOES NOT:

- Control DEX pricing
- Intervene in AMM behavior
- Manage liquidity post-lock
- Influence external trading activity

Liquidity exists fully outside protocol control boundaries.

---

## 10. Trust Model for Liquidity

Trust assumptions:

- DEX smart contracts operate correctly
- LP lock/burn mechanism is executed as defined
- No privileged access exists after liquidity finalization

After LP locking:

→ Trust requirement for liquidity becomes ZERO

---

## 11. Failure Containment Model

If liquidity system fails:

- Token contract remains unaffected
- Staking system remains operational
- Vesting remains unaffected
- Governance remains functional

✔ Liquidity failure is isolated from protocol core

---

## 12. External Dependency Risks

Liquidity system depends on:

- DEX smart contract integrity
- Blockchain network stability (Polygon)
- Market participant behavior

These are external systemic risks, not protocol-controlled risks.

---

## 13. Final Statement

The Liquidity Launch Model ensures that PNJC operates under a fully decentralized market formation process where:

- Liquidity is externally governed
- Price is algorithmically determined
- Post-launch liquidity control is permanently removed

This guarantees a trust-minimized liquidity structure aligned with DeFi standards.
