# ⏳ Execution Lifecycle — PanjoCoin (PNJC)
## Protocol Temporal Model (Time-Based System Flow)

---

## 1. Overview

This document defines the **temporal behavior of the PanjoCoin (PNJC) protocol**.

Unlike architecture (structure), this model describes:

> how the system evolves over time after deployment

It formalizes lifecycle phases from genesis to maturity.

---

## 2. Lifecycle Principle

The PNJC protocol is not static.

It operates as a **phase-evolving system**, where each stage activates different subsystems while preserving core invariants.

---

## 3. Phase 0 — Deployment Phase (Genesis)

### State:
- Smart contracts deployed
- Token supply initialized
- No market activity yet

### Active components:
- PNJC Token Contract (core)
- Initial multisig setup

### System behavior:
- No trading liquidity
- No staking rewards
- No vesting unlocks

✔ System is inert but fully defined

---

## 4. Phase 1 — Liquidity Initialization

### Trigger:
- First LP creation on DEX (Uniswap / Quickswap)

### State changes:
- AMM pool activated
- Market price formation begins

### Active components:
- Liquidity Layer (ON)
- Token Layer (ON)

### System behavior:
- Price discovery starts
- Volatility is high
- External trading begins

---

## 5. Phase 2 — Market Formation

### State:
- Active trading volume
- Arbitrage mechanisms stabilize price

### Active components:
- Liquidity Layer (FULL)
- Token Layer (FULL)
- Staking may activate

### System behavior:
- Market-driven valuation
- No internal price control
- Liquidity depth increases over time

---

## 6. Phase 3 — Ecosystem Activation

### Trigger:
- Staking contracts enabled
- Community participation increases

### Active components:
- Staking Layer (ON)
- Liquidity Layer (ON)
- Token Layer (ON)

### System behavior:
- Token utility expands
- Reward distribution begins
- Long-term holding incentives activate

---

## 7. Phase 4 — Vesting Release Period

### State:
- Locked allocations begin scheduled release

### Active components:
- Vesting Layer (ON)
- Token Layer (ON)

### System behavior:
- Controlled token emission from vesting contracts
- No manual intervention possible
- Supply distribution gradually enters circulation

---

## 8. Phase 5 — Governance Transition Phase

### Trigger:
- DAO infrastructure activation

### State:
- Multisig control reduced
- DAO governance introduced

### Active components:
- Governance Layer (HYBRID)

### System behavior:
- Proposal-based decision-making begins
- Treasury control gradually decentralized
- Protocol authority distributed

---

## 9. Phase 6 — Mature Protocol State

### State:
- Fully operational ecosystem
- Stable liquidity and governance systems

### Active components:
- All layers active

### System behavior:
- Predictable economic flows
- Governance-driven evolution
- Market-driven price equilibrium

---

## 10. Temporal Dependency Model
