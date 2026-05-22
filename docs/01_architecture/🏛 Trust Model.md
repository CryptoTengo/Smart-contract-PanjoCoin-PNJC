# 🏛 Trust Model — PanjoCoin (PNJC)

---

## 1. Overview

The PanjoCoin (PNJC) Trust Model defines how control, permissions, and risks are distributed across the protocol architecture.

The goal of this model is to ensure transparency, minimize centralized control risk, and clearly define system boundaries between immutable components and governed components.

---

## 2. System Trust Architecture

The PNJC protocol is structured into four distinct trust layers:

### 1. Immutable Layer
### 2. Multisignature Governance Layer
### 3. Vesting & Time-Locked Layer
### 4. DAO Governance Layer (Future Phase)

Each layer has strictly defined permissions and cannot operate outside its designated scope.

---

## 3. Immutable Components (No Trust Required)

The following components are immutable after deployment:

- ERC-20 Token Contract (PNJC.sol)
- Fixed total supply (no mint function)
- Core token transfer logic

### Properties:

- No minting capability exists
- No supply expansion is possible
- Token contract logic is non-upgradable (unless explicitly stated in deployment)

### Trust Assumption:

Users do not need to trust any operator for token supply integrity.

---

## 4. Multisignature Governance Layer (Operational Trust)

The multisignature wallet governs operational protocol functions:

- Treasury management
- Ecosystem funding allocation
- Administrative parameter execution (if applicable)

### Properties:

- Requires multiple independent signatures (M-of-N model)
- No single wallet can execute unilateral actions
- Signers are distributed across trusted participants

### Risk Boundary:

- Centralization risk exists only in early-stage operations
- Mitigated via distributed signer structure

---

## 5. Vesting & Time-Locked Layer (Programmable Trust)

The vesting system governs:

- Team allocations
- Founder allocations
- Early contributor distributions

### Properties:

- Tokens are locked via smart contracts
- Linear or cliff-based release schedules
- No manual intervention required for unlocks

### Trust Assumption:

Users do not need to trust individuals — only smart contract logic.

---

## 6. Liquidity Layer (DEX Trust Boundary)

Liquidity is provided on decentralized exchanges:

- Uniswap (Polygon)
- Quickswap

### Properties:

- Liquidity is added at launch
- LP tokens are intended to be locked or burned
- No backend control over liquidity removal after locking

### Trust Boundary:

After LP locking/burning, liquidity becomes effectively immutable.

---

## 7. DAO Governance Layer (Future Phase)

The DAO layer represents the future decentralized governance system:

- Community voting
- Proposal execution
- Treasury governance evolution

### Current Status:

- Not fully active at launch
- Will progressively replace multisig governance over time

### Design Goal:

Reduce reliance on multisig governance and transition toward fully decentralized control.

---

## 8. Trust Separation Model

PNJC enforces strict separation of control domains:

| Layer | Control Type | Trust Requirement |
|------|-------------|------------------|
| Token Contract | Immutable | None |
| Liquidity Pool | Locked/Burned | None after lock |
| Treasury | Multisig | Partial trust |
| Vesting Contracts | Smart contract logic | Minimal trust |
| DAO | Future decentralized system | Community trust |

---

## 9. Key Trust Guarantees

The protocol guarantees:

- Fixed token supply (no inflation risk from minting)
- Transparent on-chain allocation
- Separation of treasury and liquidity control
- Programmable vesting enforcement
- Progressive decentralization roadmap

---

## 10. Residual Risks

Despite the trust model design, the following risks remain:

- Multisig centralization risk (early stage)
- Smart contract vulnerability risk
- Market and liquidity volatility
- Governance transition uncertainty

---

## 11. Final Statement

The PanjoCoin Trust Model is designed to minimize reliance on human trust by maximizing on-chain enforcement.

Where trust is required, it is explicitly scoped, limited, and distributed.

The long-term objective is full transition toward DAO-based decentralized governance.
