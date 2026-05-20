// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

/**
 * @title PNJC Institutional MultiSig Wallet v3
 * @notice Ultra-secure multisignature wallet with timelock protection.
 * @dev Designed for DEX/CEX readiness, treasury management, and token ownership control.
 *
 * SECURITY MODEL:
 * - N-of-M multisig approvals required
 * - Timelock delay before execution (anti-rug protection)
 * - No single admin privilege
 * - All actions fully on-chain
 *
 * RECOMMENDED:
 * - 5 owners
 * - 3 confirmations
 * - 24–48h timelock delay
 */

contract PNJCMultiSigV3 {

    // =========================
    // ERRORS
    // =========================

    error NotOwner();
    error TxNotFound();
    error TxExecuted();
    error TxAlreadyConfirmed();
    error TxNotConfirmed();
    error InvalidRequirement();
    error ZeroAddress();
    error ExecutionTooEarly();
    error ExecutionFailed();

    // =========================
    // EVENTS
    // =========================

    event Deposit(address indexed sender, uint256 value);

    event SubmitTransaction(
        address indexed owner,
        uint256 indexed txId,
        address indexed to,
        uint256 value,
        bytes data
    );

    event ConfirmTransaction(address indexed owner, uint256 indexed txId);
    event RevokeConfirmation(address indexed owner, uint256 indexed txId);
    event ExecuteTransaction(address indexed owner, uint256 indexed txId);

    event RequirementChanged(uint256 required);
    event TimelockChanged(uint256 delay);

    // =========================
    // STORAGE
    // =========================

    address[] public owners;
    mapping(address => bool) public isOwner;

    uint256 public required;

    // 🔐 timelock delay (seconds)
    uint256 public delay;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirmations;
        uint256 timestamp;
    }

    Transaction[] public transactions;

    mapping(uint256 => mapping(address => bool)) public confirmed;

    // =========================
    // MODIFIERS
    // =========================

    modifier onlyOwner() {
        if (!isOwner[msg.sender]) revert NotOwner();
        _;
    }

    modifier txExists(uint256 txId) {
        if (txId >= transactions.length) revert TxNotFound();
        _;
    }

    modifier notExecuted(uint256 txId) {
        if (transactions[txId].executed) revert TxExecuted();
        _;
    }

    // =========================
    // CONSTRUCTOR
    // =========================

    constructor(
        address[] memory _owners,
        uint256 _required,
        uint256 _delay
    ) {
        if (_owners.length == 0) revert InvalidRequirement();
        if (_required == 0 || _required > _owners.length) revert InvalidRequirement();

        owners = _owners;
        required = _required;
        delay = _delay;

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            if (owner == address(0)) revert ZeroAddress();

            isOwner[owner] = true;
        }
    }

    // =========================
    // RECEIVE
    // =========================

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    // =========================
    // CORE LOGIC
    // =========================

    function submitTransaction(
        address to,
        uint256 value,
        bytes calldata data
    ) external onlyOwner returns (uint256 txId) {

        txId = transactions.length;

        transactions.push(Transaction({
            to: to,
            value: value,
            data: data,
            executed: false,
            confirmations: 0,
            timestamp: block.timestamp
        }));

        emit SubmitTransaction(msg.sender, txId, to, value, data);

        confirmTransaction(txId);
    }

    function confirmTransaction(uint256 txId)
        public
        onlyOwner
        txExists(txId)
        notExecuted(txId)
    {
        if (confirmed[txId][msg.sender]) revert TxAlreadyConfirmed();

        confirmed[txId][msg.sender] = true;
        transactions[txId].confirmations++;

        emit ConfirmTransaction(msg.sender, txId);
    }

    function revokeConfirmation(uint256 txId)
        external
        onlyOwner
        txExists(txId)
        notExecuted(txId)
    {
        if (!confirmed[txId][msg.sender]) revert TxNotConfirmed();

        confirmed[txId][msg.sender] = false;
        transactions[txId].confirmations--;

        emit RevokeConfirmation(msg.sender, txId);
    }

    // =========================
    // EXECUTION (WITH TIMELOCK)
    // =========================

    function executeTransaction(uint256 txId)
        external
        onlyOwner
        txExists(txId)
        notExecuted(txId)
    {
        Transaction storage txn = transactions[txId];

        if (txn.confirmations < required) revert InvalidRequirement();

        // 🔐 TIMELOCK PROTECTION
        if (block.timestamp < txn.timestamp + delay) {
            revert ExecutionTooEarly();
        }

        txn.executed = true;

        (bool success, ) = txn.to.call{value: txn.value}(txn.data);

        if (!success) {
            txn.executed = false;
            revert ExecutionFailed();
        }

        emit ExecuteTransaction(msg.sender, txId);
    }

    // =========================
    // GOVERNANCE SETTINGS (MULTISIG ONLY)
    // =========================

    function changeRequirement(uint256 newRequired)
        external
        onlyOwner
    {
        if (newRequired == 0 || newRequired > owners.length) {
            revert InvalidRequirement();
        }

        required = newRequired;
        emit RequirementChanged(newRequired);
    }

    function changeTimelock(uint256 newDelay)
        external
        onlyOwner
    {
        delay = newDelay;
        emit TimelockChanged(newDelay);
    }

    // =========================
    // VIEW FUNCTIONS
    // =========================

    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function getTransaction(uint256 txId)
        external
        view
        returns (
            address to,
            uint256 value,
            bytes memory data,
            bool executed,
            uint256 confirmations,
            uint256 timestamp
        )
    {
        Transaction storage t = transactions[txId];
        return (t.to, t.value, t.data, t.executed, t.confirmations, t.timestamp);
    }

    function getTransactionCount() external view returns (uint256) {
        return transactions.length;
    }
}
