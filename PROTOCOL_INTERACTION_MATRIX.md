📄 Название файла: `PROTOCOL_INTERACTION_MATRIX.md`

---

# 🧠 PanjoCoin (PNJC) — Protocol Interaction Matrix v1.0

## Execution Truth Table of Smart Contract System

---

# 1. 📌 Overview

This document defines the **execution-level interaction model** of the PanjoCoin (PNJC) protocol.

It specifies:

* Who calls whom (contract-to-contract execution flow)
* Execution order of system modules
* State changes per interaction
* Constraints and invariants per call
* Cross-contract dependencies

This is the **canonical “execution truth table” of the entire protocol**.

---

# 2. 🧩 System Components

The protocol consists of the following modules:

* **PNJC Token Contract**
* **PNJC_Staking Contract**
* **PNJC_Vesting_Cliff Contract**
* **PNJC_Free_Router Contract**
* **PNJC_Airdrop Contract**
* **PNJC_Multisig Governance Contract**

---

# 3. 🔄 Core Interaction Principles

The system follows:

* ✔ Strict separation of concerns
* ✔ Unidirectional token flow logic
* ✔ No circular mint dependencies
* ✔ Multisig-controlled governance layer
* ✔ Time-based vesting constraints

---

# 4. 🧠 Global Execution Flow Model

[
System(t) = f(Token, Staking, Vesting, Liquidity, Governance)
]

Each module modifies **only its defined state domain**.

---

# 5. 🔁 Protocol Interaction Matrix (CORE)

## 5.1 Token → Staking Flow

| Step | Caller  | Callee           | Action          | State Change                  | Constraints              |
| ---- | ------- | ---------------- | --------------- | ----------------------------- | ------------------------ |
| 1    | User    | Staking Contract | stake()         | tokens locked                 | balance must be ≥ amount |
| 2    | Staking | PNJC Token       | transferFrom()  | tokens moved to staking vault | approval required        |
| 3    | Staking | Reward Logic     | updateRewards() | reward accrual updated        | deterministic only       |

### Invariants:

* ( S_{staked}(user) \leq S_{wallet}(user) )
* No reward mint beyond emission cap

---

## 5.2 Vesting → Token Release Flow

| Step | Caller           | Callee      | Action     | State Change    | Constraints             |
| ---- | ---------------- | ----------- | ---------- | --------------- | ----------------------- |
| 1    | Vesting Contract | PNJC Token  | unlock()   | tokens released | must pass cliff         |
| 2    | Vesting Contract | User Wallet | transfer() | balance updated | time condition verified |

### Invariants:

* No unlock before cliff:
  [
  t < t_{cliff} \Rightarrow transfer = 0
  ]

---

## 5.3 Router → AMM Execution Flow

| Step | Caller | Callee         | Action        | State Change        | Constraints                |
| ---- | ------ | -------------- | ------------- | ------------------- | -------------------------- |
| 1    | User   | Router         | swap()        | execution initiated | slippage check required    |
| 2    | Router | Liquidity Pool | executeSwap() | reserves updated    | must satisfy AMM invariant |
| 3    | Pool   | PNJC Token     | transfer()    | balances updated    | route must be approved     |

### Invariants:

* Constant product rule:
  [
  x \cdot y = k
  ]

* Slippage bound:
  [
  |P_{exec} - P_{expected}| \leq \delta
  ]

---

## 5.4 Multisig → Governance Control Flow

| Step | Caller           | Callee          | Action    | State Change        | Constraints              |
| ---- | ---------------- | --------------- | --------- | ------------------- | ------------------------ |
| 1    | Signers (k-of-n) | Multisig        | propose() | proposal created    | threshold required       |
| 2    | Signers          | Multisig        | approve() | confirmations added | no single signer control |
| 3    | Multisig         | Target Contract | execute() | state modified      | timelock enforced        |

### Invariants:

* Execution only if:
  [
  signatures \geq k
  ]

---

## 5.5 Airdrop → Distribution Flow

| Step | Caller           | Callee     | Action       | State Change     | Constraints         |
| ---- | ---------------- | ---------- | ------------ | ---------------- | ------------------- |
| 1    | Airdrop Contract | PNJC Token | distribute() | tokens allocated | eligibility check   |
| 2    | User             | Airdrop    | claim()      | balance updated  | no duplicate claims |

### Invariants:

* One wallet → one claim
* Sybil resistance enforced at logic layer

---

# 6. ⚙️ Cross-Contract Dependency Graph

```
Multisig
   ↓
Vesting → Token
   ↓
Staking → Token
   ↓
Router → Liquidity Pool → Token
   ↓
Airdrop → Token
```

---

# 7. 🧠 State Transition Rules

## 7.1 Allowed Transitions

* Initialization → Vesting
* Vesting → Circulation
* Circulation → Staking
* Staking → Reward Accrual
* Governance → System Parameter Update

---

## 7.2 Forbidden Transitions

* Vesting → Direct Mint (❌ forbidden)
* Staking → Mint inflation (❌ forbidden)
* Router → Governance modification (❌ forbidden)
* Airdrop → Unlimited repeat claims (❌ forbidden)

---

# 8. 🔐 System-Wide Invariants

## 8.1 Supply Integrity

[
TotalSupply = Circulating + Staked + Locked
]

---

## 8.2 No Unauthorized Mint

Only authorized governance or contract logic may mint (if enabled).

---

## 8.3 Deterministic Execution

All state changes are deterministic:

[
State_{t+1} = f(State_t, Input)
]

---

## 8.4 Cross-System Consistency

No contract can violate global supply invariants.

---

# 9. ⚠️ Execution Safety Constraints

* No recursive token mint loops
* No cross-contract reentrancy paths
* No unauthorized state mutation
* No off-schedule vesting execution
* No router external call injection

---

# 10. 🧾 System Interpretation Layer

This matrix ensures:

✔ Predictable contract execution order
✔ Fully traceable state transitions
✔ No hidden execution paths
✔ Deterministic DeFi logic
✔ Formal interaction correctness

---

# 11. 🏁 Final Statement

> The PanjoCoin protocol is defined as a deterministic multi-contract execution system with strictly ordered interactions, enforced invariants, and formally verified state transitions across staking, vesting, liquidity, governance, and distribution layers.

---

# 🚀 Result (CertiK Interpretation)

This document provides:

* ✔ Full execution truth table
* ✔ Cross-contract interaction specification
* ✔ State transition formal model
* ✔ Governance execution flow
* ✔ AMM + staking + vesting integration logic
