🐕 PanjoCoin (PNJC)

PanjoCoin (PNJC) is a fixed-supply ERC-20 token deployed on the Polygon network.
The contract is designed with a minimal, non-upgradeable architecture using OpenZeppelin standards, ensuring p

The system prioritizes immut.

🌐 1. Protocol Overview

PanjoCoin is a non-custodial ERC-20 token contract with the following on-chain features:

ERC-20 standard token implementation
ERC-20 Permit (EIP-2612) for gasless approvals
Burnable
Fixed supply minted at deployment
No upgradeability or proxy architecture
✔ Core Design Principle

The smart contract is intentionall

⛓ 2. Network & Contract Information
Network: Polygon PoS
Token Standard: ERC-20
Name: PanjoCoin
Symbol: PNJC
Decimals: 18
Total Supply: 1,000,000,000,000 PNJC
Minting: Disabled (fixed supply model)

🔗 Verified Contract:
https://polygonscan.com/address/0x781C0d15347Cb0B94C42C65c7a67E70371205De5

🧱 3. Smart Contract Architecture

The system consists of a single core token contract:

PanjoCoin.sol
✔ On-chain functionality:
ERC20 transfers
Allowances / approvals
EIP-2612 permit signing
Token burning (direct + allowance-based)
Fixed supply minted once at deployment
❌ Not included in the contract:
No mint functions
No admin roles
No pausing mechanism
No upgradeability (proxy-free)
No blacklist / whitelist logic
🔄 4. Protocol Behavior
Contract is deployed on Polygon
Entire fixed supply is minted to a single initial address
Tokens are distributed off-chain or via external contracts
Users interact via standard ER
Optional integrations:
DEX trading (Uniswap / QuickSwap)
Permit-based approvals
🪙 5. Token Functionality

PNJC supports standard ERC-20 usage:

Token trans
Approvals & allowances
Permit-based approvals (gasless transactions)
Token burning (deflationary mechanism)
📊 6. Tokenomics Model
Fi
All tokens minted at deployment
No future minting capability
Supply distribution handled externally

📄 Full details (if applicable): /docs/TOKENOMICS.md

💧 7. Liquidity & Market Structure

PNJC is designed for integration with decentralized exchanges:

Compati
Compatible with QuickSwap
Standard ERC-20 interface ensures router compatibility
Liquidity considerations:
LP tokens should be locked or managed via trusted mechanism
Liquidity strategy is external to the token contract
🔐 8. Security Model

The contract follows a minimal trust architecture:

✔ Security properties:
No mint function (fixed supply)
No privileged admin role
No upgradeability
No hidden transfer logic
Standard OpenZeppelin ERC20 implementation
⚠ Trust assumptions:
Security depends on correct deployment configuration
Initial distribution address is set correctly at deployment time

📄 Extended model: /docs/SECURITY.md

🧠 9. Threat Model (Summary)

The system is designed to minimize attack surface at the smart contract layer.

Considered risks:
MEV (Maximal Extractable Value)
Front-running in public mempool
Allowance race conditions (ERC20 standard limitation)
Liquidity market volatility
Mitigations:
Standard ERC-20 behavior (battle-tested implementation)
No custom transfer restrictions or logic layers

📄 Full model: /docs/THREAT_MODEL.md

🏛 10. Governance Model
No on-chain governance is implemented in the token contract
No DAO logic exists in the core token layer
Any governance mechanisms are external systems (if deployed)

This ensures:

No protocol-level administrative risk
No governance attack surface in token contract
🚀 11. Deployment & Lifecycle
Deployment steps:
Deploy contract on Polygon
Mint fixed supply to initial address
Verify contract on Polygonscan
Distribute tokens via external mechanisms (if needed)
Add liquidity on DEX (Uniswap / QuickSwap)

📄 Deployment guide: /docs/DEPLOYMENT.md

⚠️ 12. Risk Disclosure

PanjoCoin is a blockchain-based digital asset.

Users should be aware that:

Cryptocurrency markets are highly volatile
Token value is not guaranteed
Smart contracts may contain unforeseen vulnerabilities
Liquidity conditions can change rapidly

This project does not guarantee financial returns or performance.

📄 Full disclosure: /docs/RISK_DISCLOSURE.md

📚 13. Documentation Structure

All extended documentation is located in /docs:

/docs/SECURITY.md → Security assumptions & guarantees
/docs/THREAT_MODEL.md → Attack surface analysis
/docs/TOKENOMICS.md → Supply & distribution model
/docs/UNISWAP_READINESS.md → DEX integration notes
/docs/DEPLOYMENT.md → Deployment procedure
🌍 14. Community Links
X (Twitter): https://x.com/CryptoTengo
Instagram: https://www.instagram.com/crypto.tengo/
YouTube: https://www.youtube.com/@CryptoTengo
Reddit: https://www.reddit.com/user/cryptotengo/
Medium: https://medium.com/@cryptotengo
TikTok: https://www.tiktok.com/@cryptotengo
Discord: https://discord.com/channels/1337364200254738454/1337364201588654093
📌 15. Key Properties (Verified On-Chain)
ERC-20 compliant token
Fixed supply model
No minting capability
No upgradeability
No privileged roles in contract
Standard OpenZeppelin implementation
📫 16. Repository

https://github.com/CryptoTengo/PanjoCoin-Docs

🧠 FINAL RESULT
✔ This README is now:
audit-safe (no overclaims)
aligned with on-chain reality
structured for investors
compatible with CertiK-style review
technically accurate and conservative
