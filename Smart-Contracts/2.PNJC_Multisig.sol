 // SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title PNJC Governance Multisig (3-of-5 Safe-Grade Implementation)
 *
 * @notice
 * This contract is a hardened multisignature governance layer for PNJC protocol.
 * It is designed to replicate Safe-level security patterns in a minimal custom implementation.
 *
 * @dev SECURITY MODEL:
 *
 * - Requires 3-of-5 independent signers
 * - No single signer can execute transactions
 * - No upgradeability or admin override
 * - Fully deterministic execution flow
 * - Replay-safe transaction system via nonce tracking
 *
 * INVESTOR NOTE:
 * This contract ensures decentralized governance over all PNJC protocol components:
 * ERC20 token, staking, vesting, treasury, and liquidity management.
 *
 * AUDIT NOTE:
 * This implementation introduces additional safeguards:
 * - Owner uniqueness validation
 * - Zero-address protection
 * - Nonce-based execution safety
 * - Explicit call success validation
 */

contract PNJC_Multisig_3of5 is ReentrancyGuard {
    using Address for address;

    // =============================================================
    // 🔐 GOVERNANCE STATE
    // =============================================================

    address[] public owners;

    uint256 public constant REQUIRED = 3;

    /**
     * @dev Nonce prevents replay attacks and ensures transaction uniqueness
     */
    uint256 public nonce;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirmations;
    }

    mapping(uint256 => Transaction) public transactions;
    mapping(uint256 => mapping(address => bool)) public confirmed;

    // =============================================================
    // 📢 EVENTS (FULL TRANSPARENCY FOR AUDIT)
    // =============================================================

    event SubmitTransaction(
        address indexed owner,
        uint256 indexed txId,
        address indexed to,
        uint256 value,
        bytes data
    );

    event ConfirmTransaction(address indexed owner, uint256 indexed txId);

    event ExecuteTransaction(address indexed executor, uint256 indexed txId);

    event RevokeConfirmation(address indexed owner, uint256 indexed txId);

    // =============================================================
    // 🛡 MODIFIERS
    // =============================================================

    modifier onlyOwner() {
        require(isOwner(msg.sender), "PNJC: Not authorized signer");
        _;
    }

    modifier txExists(uint256 _txId) {
        require(_txId < nonce, "PNJC: Invalid transaction");
        _;
    }

    modifier notExecuted(uint256 _txId) {
        require(!transactions[_txId].executed, "PNJC: Already executed");
        _;
    }

    modifier notConfirmed(uint256 _txId) {
        require(!confirmed[_txId][msg.sender], "PNJC: Already confirmed");
        _;
    }

    // =============================================================
    // 🏗 CONSTRUCTOR (SAFE-STYLE INITIALIZATION)
    // =============================================================

    /**
     * @notice Initializes multisig governance
     *
     * @param _owners Array of exactly 5 independent signers
     *
     * @dev SECURITY REQUIREMENTS:
     * - Exactly 5 owners required
     * - No zero address allowed
     * - No duplicate owners allowed
     * - Immutable after deployment
     */
    constructor(address[] memory _owners) {
        require(_owners.length == 5, "PNJC: Must have exactly 5 owners");

        for (uint256 i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "PNJC: zero address");
            for (uint256 j = i + 1; j < _owners.length; j++) {
                require(_owners[i] != _owners[j], "PNJC: duplicate owner");
            }
        }

        owners = _owners;
    }

    // =============================================================
    // 📌 CORE LOGIC
    // =============================================================

    /**
     * @notice Submit a governance transaction proposal
     *
     * @dev Step 1: creates immutable transaction record
     */
    function submitTransaction(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner {
        require(_to != address(0), "PNJC: invalid target");

        transactions[nonce] = Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            confirmations: 0
        });

        emit SubmitTransaction(msg.sender, nonce, _to, _value, _data);

        nonce++;
    }

    /**
     * @notice Confirm a transaction
     *
     * @dev Each owner can confirm only once per transaction
     */
    function confirmTransaction(uint256 _txId)
        external
        onlyOwner
        txExists(_txId)
        notExecuted(_txId)
        notConfirmed(_txId)
    {
        confirmed[_txId][msg.sender] = true;
        transactions[_txId].confirmations++;

        emit ConfirmTransaction(msg.sender, _txId);

        if (transactions[_txId].confirmations >= REQUIRED) {
            executeTransaction(_txId);
        }
    }

    /**
     * @notice Execute transaction after reaching threshold
     *
     * @dev
     * Uses low-level call with explicit success validation.
     * Protected by reentrancy guard.
     */
    function executeTransaction(uint256 _txId)
        public
        txExists(_txId)
        notExecuted(_txId)
        nonReentrant
    {
        require(
            transactions[_txId].confirmations >= REQUIRED,
            "PNJC: insufficient confirmations"
        );

        Transaction storage txn = transactions[_txId];
        txn.executed = true;

        (bool success, bytes memory returndata) =
            txn.to.call{value: txn.value}(txn.data);

        require(success, "PNJC: external call failed");

        // Optional: bubble revert reason for better debugging
        if (!success && returndata.length > 0) {
            assembly {
                revert(add(returndata, 32), mload(returndata))
            }
        }

        emit ExecuteTransaction(msg.sender, _txId);
    }

    /**
     * @notice Revoke confirmation before execution
     */
    function revokeConfirmation(uint256 _txId)
        external
        onlyOwner
        txExists(_txId)
        notExecuted(_txId)
    {
        require(confirmed[_txId][msg.sender], "PNJC: not confirmed");

        confirmed[_txId][msg.sender] = false;
        transactions[_txId].confirmations--;

        emit RevokeConfirmation(msg.sender, _txId);
    }

    // =============================================================
    // 🔎 VIEW FUNCTIONS
    // =============================================================

    function isOwner(address _addr) public view returns (bool) {
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == _addr) return true;
        }
        return false;
    }

    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function getTransaction(uint256 _txId)
        external
        view
        returns (Transaction memory)
    {
        return transactions[_txId];
    }

    // =============================================================
    // 💰 RECEIVE
    // =============================================================

    receive() external payable {}
}
