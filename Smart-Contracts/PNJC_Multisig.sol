// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

/**
 * @title PNJCMultiSig
 * @author PanjoCoin Engineering Team
 * @notice Institutional-grade multi-signature wallet with timelock and transaction expiry.
 *
 * @dev SECURITY OVERVIEW
 * ----------------------------------------------------------------------------
 * This contract is designed to secure treasury assets, protocol ownership,
 * and critical administrative privileges such as:
 *
 * - Ownership of ERC20 token contracts
 * - Control of TimelockController
 * - Management of treasury wallets
 * - Control of fee routers and airdrop contracts
 *
 * Core security properties:
 * - N-of-M consensus for all privileged actions
 * - Configurable execution delay (timelock)
 * - Transaction expiration protection
 * - Reentrancy protection
 * - Full on-chain audit trail
 * - Self-governed owner management
 *
 * Recommended production setup:
 * - Owners: 3 to 7 trusted signers
 * - Required confirmations: majority (e.g. 3-of-5)
 * - Timelock: 24 to 72 hours
 *
 * AUDIT INVARIANTS
 * ----------------------------------------------------------------------------
 * 1. No transaction can execute without `required` confirmations.
 * 2. No transaction can execute before `delay` has elapsed.
 * 3. No transaction can execute after expiration.
 * 4. Owners can only be added/removed through the multisig itself.
 * 5. Confirmation threshold is always between 1 and owner count.
 * 6. Executed transactions can never be executed twice.
 */

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract PNJCMultiSig is ReentrancyGuard {
    // =========================================================================
    // CONSTANTS
    // =========================================================================

    /// @notice Maximum time a submitted transaction remains valid.
    uint256 public constant VALIDITY_PERIOD = 14 days;

    // =========================================================================
    // ERRORS
    // =========================================================================

    error NotOwner();
    error OnlyWallet();
    error ZeroAddress();
    error InvalidRequirement();
    error OwnerAlreadyExists();
    error OwnerDoesNotExist();

    error TransactionNotFound();
    error TransactionAlreadyExecuted();
    error TransactionExpired();
    error TransactionAlreadyConfirmed();
    error TransactionNotConfirmed();

    error InsufficientConfirmations();
    error ExecutionTooEarly();
    error ExecutionFailed();

    // =========================================================================
    // EVENTS
    // =========================================================================

    /// @notice Emitted when the wallet receives native currency.
    event Deposit(address indexed sender, uint256 amount, uint256 balance);

    /// @notice Emitted when a new transaction is submitted.
    event TransactionSubmitted(
        address indexed owner,
        uint256 indexed txId,
        address indexed to,
        uint256 value,
        bytes data
    );

    /// @notice Emitted when an owner confirms a transaction.
    event TransactionConfirmed(address indexed owner, uint256 indexed txId);

    /// @notice Emitted when an owner revokes a confirmation.
    event ConfirmationRevoked(address indexed owner, uint256 indexed txId);

    /// @notice Emitted when a transaction is executed.
    event TransactionExecuted(address indexed executor, uint256 indexed txId);

    /// @notice Emitted when a new owner is added.
    event OwnerAdded(address indexed owner);

    /// @notice Emitted when an owner is removed.
    event OwnerRemoved(address indexed owner);

    /// @notice Emitted when the confirmation threshold changes.
    event RequirementChanged(uint256 newRequirement);

    /// @notice Emitted when the timelock delay changes.
    event TimelockChanged(uint256 newDelay);

    // =========================================================================
    // STRUCTS
    // =========================================================================

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirmations;
        uint256 submittedAt;
    }

    // =========================================================================
    // STORAGE
    // =========================================================================

    address[] private _owners;
    mapping(address => bool) public isOwner;

    // txId => owner => confirmed
    mapping(uint256 => mapping(address => bool)) public confirmed;

    Transaction[] private _transactions;

    /// @notice Number of confirmations required to execute a transaction.
    uint256 public required;

    /// @notice Minimum delay before an approved transaction may be executed.
    uint256 public delay;

    // =========================================================================
    // MODIFIERS
    // =========================================================================

    modifier onlyOwner() {
        if (!isOwner[msg.sender]) revert NotOwner();
        _;
    }

    modifier onlyWallet() {
        if (msg.sender != address(this)) revert OnlyWallet();
        _;
    }

    modifier txExists(uint256 txId) {
        if (txId >= _transactions.length) revert TransactionNotFound();
        _;
    }

    modifier notExecuted(uint256 txId) {
        if (_transactions[txId].executed) {
            revert TransactionAlreadyExecuted();
        }
        _;
    }

    modifier notExpired(uint256 txId) {
        if (
            block.timestamp >
            _transactions[txId].submittedAt + VALIDITY_PERIOD
        ) {
            revert TransactionExpired();
        }
        _;
    }

    // =========================================================================
    // CONSTRUCTOR
    // =========================================================================

    /**
     * @param owners_ Initial list of unique wallet owners.
     * @param required_ Number of confirmations required for execution.
     * @param delay_ Timelock delay in seconds.
     */
    constructor(
        address[] memory owners_,
        uint256 required_,
        uint256 delay_
    ) {
        uint256 length = owners_.length;

        if (length == 0) revert InvalidRequirement();
        if (required_ == 0 || required_ > length) {
            revert InvalidRequirement();
        }

        for (uint256 i = 0; i < length; ++i) {
            address owner = owners_[i];

            if (owner == address(0)) revert ZeroAddress();
            if (isOwner[owner]) revert OwnerAlreadyExists();

            isOwner[owner] = true;
            _owners.push(owner);
        }

        required = required_;
        delay = delay_;
    }

    // =========================================================================
    // RECEIVE
    // =========================================================================

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    // =========================================================================
    // TRANSACTION SUBMISSION
    // =========================================================================

    /**
     * @notice Submit a new transaction proposal.
     * @dev The submitter automatically confirms the transaction.
     *
     * @param to Destination address.
     * @param value Native currency amount to send.
     * @param data Calldata payload.
     *
     * @return txId Newly created transaction ID.
     */
    function submitTransaction(
        address to,
        uint256 value,
        bytes calldata data
    ) external onlyOwner returns (uint256 txId) {
        if (to == address(0)) revert ZeroAddress();

        txId = _transactions.length;

        _transactions.push(
            Transaction({
                to: to,
                value: value,
                data: data,
                executed: false,
                confirmations: 0,
                submittedAt: block.timestamp
            })
        );

        emit TransactionSubmitted(msg.sender, txId, to, value, data);

        _confirmTransaction(txId, msg.sender);
    }

    // =========================================================================
    // CONFIRMATIONS
    // =========================================================================

    function confirmTransaction(
        uint256 txId
    )
        external
        onlyOwner
        txExists(txId)
        notExecuted(txId)
        notExpired(txId)
    {
        _confirmTransaction(txId, msg.sender);
    }

    function revokeConfirmation(
        uint256 txId
    )
        external
        onlyOwner
        txExists(txId)
        notExecuted(txId)
        notExpired(txId)
    {
        if (!confirmed[txId][msg.sender]) {
            revert TransactionNotConfirmed();
        }

        confirmed[txId][msg.sender] = false;
        _transactions[txId].confirmations--;

        emit ConfirmationRevoked(msg.sender, txId);
    }

    function _confirmTransaction(uint256 txId, address owner) internal {
        if (confirmed[txId][owner]) {
            revert TransactionAlreadyConfirmed();
        }

        confirmed[txId][owner] = true;
        _transactions[txId].confirmations++;

        emit TransactionConfirmed(owner, txId);
    }

    // =========================================================================
    // EXECUTION
    // =========================================================================

    /**
     * @notice Execute a fully approved transaction.
     *
     * Requirements:
     * - Transaction exists.
     * - Not already executed.
     * - Not expired.
     * - Enough confirmations.
     * - Timelock delay has elapsed.
     */
    function executeTransaction(
        uint256 txId
    )
        external
        onlyOwner
        txExists(txId)
        notExecuted(txId)
        notExpired(txId)
        nonReentrant
    {
        Transaction storage txn = _transactions[txId];

        if (txn.confirmations < required) {
            revert InsufficientConfirmations();
        }

        if (block.timestamp < txn.submittedAt + delay) {
            revert ExecutionTooEarly();
        }

        txn.executed = true;

        (bool success, ) = txn.to.call{value: txn.value}(txn.data);

        if (!success) {
            txn.executed = false;
            revert ExecutionFailed();
        }

        emit TransactionExecuted(msg.sender, txId);
    }

    // =========================================================================
    // SELF-GOVERNED ADMINISTRATION
    // =========================================================================

    /**
     * @notice Add a new owner.
     * @dev Can only be called by the wallet itself.
     */
    function addOwner(address newOwner) external onlyWallet {
        if (newOwner == address(0)) revert ZeroAddress();
        if (isOwner[newOwner]) revert OwnerAlreadyExists();

        isOwner[newOwner] = true;
        _owners.push(newOwner);

        emit OwnerAdded(newOwner);
    }

    /**
     * @notice Remove an existing owner.
     * @dev Automatically adjusts confirmation requirement if necessary.
     */
    function removeOwner(address owner) external onlyWallet {
        if (!isOwner[owner]) revert OwnerDoesNotExist();

        isOwner[owner] = false;

        uint256 length = _owners.length;
        for (uint256 i = 0; i < length; ++i) {
            if (_owners[i] == owner) {
                _owners[i] = _owners[length - 1];
                _owners.pop();
                break;
            }
        }

        if (required > _owners.length) {
            required = _owners.length;
            emit RequirementChanged(required);
        }

        emit OwnerRemoved(owner);
    }

    /**
     * @notice Change the confirmation threshold.
     */
    function changeRequirement(uint256 newRequired) external onlyWallet {
        if (newRequired == 0 || newRequired > _owners.length) {
            revert InvalidRequirement();
        }

        required = newRequired;
        emit RequirementChanged(newRequired);
    }

    /**
     * @notice Change the timelock delay.
     */
    function changeTimelock(uint256 newDelay) external onlyWallet {
        delay = newDelay;
        emit TimelockChanged(newDelay);
    }

    // =========================================================================
    // VIEW FUNCTIONS
    // =========================================================================

    function getOwners() external view returns (address[] memory) {
        return _owners;
    }

    function getTransactionCount() external view returns (uint256) {
        return _transactions.length;
    }

    function getTransaction(
        uint256 txId
    )
        external
        view
        txExists(txId)
        returns (
            address to,
            uint256 value,
            bytes memory data,
            bool executed,
            uint256 confirmations,
            uint256 submittedAt
        )
    {
        Transaction storage txn = _transactions[txId];

        return (
            txn.to,
            txn.value,
            txn.data,
            txn.executed,
            txn.confirmations,
            txn.submittedAt
        );
    }

    /**
     * @notice Returns whether a transaction has enough confirmations.
     */
    function isConfirmed(uint256 txId)
        external
        view
        txExists(txId)
        returns (bool)
    {
        return _transactions[txId].confirmations >= required;
    }

    /**
     * @notice Returns the timestamp after which a transaction becomes executable.
     */
    function getExecutableAt(
        uint256 txId
    ) external view txExists(txId) returns (uint256) {
        return _transactions[txId].submittedAt + delay;
    }

    /**
     * @notice Returns the expiration timestamp of a transaction.
     */
    function getExpiresAt(
        uint256 txId
    ) external view txExists(txId) returns (uint256) {
        return _transactions[txId].submittedAt + VALIDITY_PERIOD;
    }
}
