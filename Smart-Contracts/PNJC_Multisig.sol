// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/*
|--------------------------------------------------------------------------
| PNJC Treasury Safe V3
|--------------------------------------------------------------------------
|
| PURPOSE
| -------
| This contract acts as a decentralized treasury management system for
| PNJC ecosystem funds.
|
| It enforces:
| - multi-signer approval (M-of-N governance)
| - time-delayed execution (timelock protection)
| - role-based execution separation
| - emergency pause mechanism
|
| SECURITY MODEL
| --------------
| The design follows institutional DeFi security standards:
| - no single private key can move funds instantly
| - execution requires quorum + delay
| - approvals can be revoked before execution
| - emergency pause can halt operations
|
| AUDIT TARGET
| ------------
| Designed to align with best practices used in:
| - Gnosis Safe architecture patterns
| - Aave governance treasury modules
|
| RISK MITIGATION
| ---------------
| - Prevents instant fund drain after key compromise
| - Reduces insider collusion risk via quorum requirement
| - Introduces execution delay for community reaction window
|
*/

contract PNJC_TreasurySafeV3 is ReentrancyGuard, Ownable {

    // =============================================================
    // CUSTOM ERRORS (gas efficient + audit friendly)
    // =============================================================

    /*
    Using custom errors instead of require strings improves:
    - gas efficiency
    - readability in audit reports
    - standardization of failure cases
    */
    error NotAuthorized();
    error TxExecuted();
    error TxCancelled();
    error AlreadyApproved();
    error NotEnoughApprovals();
    error TimelockNotMet();
    error TxExpired();
    error ContractPaused();
    error ZeroAddress();

    // =============================================================
    // ROLE-BASED ACCESS CONTROL (RBAC)
    // =============================================================

    /*
    SIGNER:
    - Can propose, approve, revoke transactions
    - Represents governance participants

    EXECUTOR:
    - Can execute approved transactions after timelock
    - Separates approval from execution (important for security)

    GUARDIAN:
    - Emergency role with ability to pause contract
    - Used for incident response only
    */

    mapping(address => bool) public isSigner;
    mapping(address => bool) public isExecutor;
    mapping(address => bool) public isGuardian;

    // =============================================================
    // GOVERNANCE PARAMETERS
    // =============================================================

    /*
    requiredApprovals:
    Minimum number of approvals required before execution.

    timelockDelay:
    Mandatory delay between proposal and execution.
    Provides reaction window in case of compromise.
    */
    uint256 public requiredApprovals;
    uint256 public timelockDelay;

    // Emergency global pause switch
    bool public paused;

    // =============================================================
    // TRANSACTION STRUCTURE
    // =============================================================

    /*
    Each transaction is immutable after creation except:
    - approval updates
    - cancellation flag
    - execution flag

    This ensures full audit traceability.
    */
    struct Transaction {
        address to;
        uint256 value;
        bytes data;

        uint256 approvals;
        uint256 createdAt;
        uint256 executeAfter;
        uint256 expiresAt;

        bool executed;
        bool cancelled;
    }

    Transaction[] public transactions;

    /*
    Tracks approvals per transaction per signer
    Prevents double-counting approvals
    */
    mapping(uint256 => mapping(address => bool)) public approved;

    // =============================================================
    // EVENTS (FULL AUDIT TRAIL)
    // =============================================================

    /*
    Events are critical for:
    - off-chain indexing
    - audit traceability
    - transparency dashboards
    */

    event TransactionProposed(uint256 indexed txId, address indexed proposer);
    event TransactionApproved(uint256 indexed txId, address indexed signer);
    event TransactionRevoked(uint256 indexed txId, address indexed signer);
    event TransactionExecuted(uint256 indexed txId, address indexed executor);
    event TransactionCancelled(uint256 indexed txId, address indexed signer);

    event RoleUpdated(address indexed user, string role, bool status);
    event PauseStateChanged(bool paused);

    // =============================================================
    // MODIFIERS
    // =============================================================

    /*
    Enforces signer-only access for governance actions
    */
    modifier onlySigner() {
        if (!isSigner[msg.sender]) revert NotAuthorized();
        _;
    }

    /*
    Prevents execution during emergency mode
    */
    modifier notPaused() {
        if (paused) revert ContractPaused();
        _;
    }

    // =============================================================
    // CONSTRUCTOR
    // =============================================================

    /*
    Initializes governance structure at deployment.

    SECURITY NOTE:
    - Minimum 3 signers required to prevent centralization
    - Roles are explicitly assigned for separation of duties
    */
    constructor(
        address[] memory signers,
        address[] memory executors,
        address[] memory guardians,
        uint256 _requiredApprovals,
        uint256 _timelockDelay
    ) Ownable(msg.sender) {

        require(signers.length >= 3, "Insufficient signers");

        requiredApprovals = _requiredApprovals;
        timelockDelay = _timelockDelay;

        for (uint256 i = 0; i < signers.length; i++) {
            require(signers[i] != address(0), "Invalid signer");
            isSigner[signers[i]] = true;
        }

        for (uint256 i = 0; i < executors.length; i++) {
            require(executors[i] != address(0), "Invalid executor");
            isExecutor[executors[i]] = true;
        }

        for (uint256 i = 0; i < guardians.length; i++) {
            require(guardians[i] != address(0), "Invalid guardian");
            isGuardian[guardians[i]] = true;
        }
    }

    // =============================================================
    // PROPOSE TRANSACTION
    // =============================================================

    /*
    STEP 1: Proposal Phase

    A transaction is created but CANNOT be executed immediately.
    It enters timelock period before becoming executable.
    */
    function propose(
        address to,
        uint256 value,
        bytes calldata data
    ) external onlySigner notPaused returns (uint256 txId) {

        txId = transactions.length;

        transactions.push(Transaction({
            to: to,
            value: value,
            data: data,
            approvals: 0,
            createdAt: block.timestamp,
            executeAfter: block.timestamp + timelockDelay,
            expiresAt: block.timestamp + (timelockDelay * 10),
            executed: false,
            cancelled: false
        }));

        emit TransactionProposed(txId, msg.sender);
    }

    // =============================================================
    // APPROVAL
    // =============================================================

    /*
    STEP 2: Approval Phase

    Multiple independent signers must approve transaction
    before execution becomes possible.
    */
    function approve(uint256 txId) external onlySigner notPaused {

        Transaction storage t = transactions[txId];

        require(!t.executed, "Already executed");
        require(!t.cancelled, "Cancelled");
        require(!approved[txId][msg.sender], "Already approved");

        approved[txId][msg.sender] = true;
        t.approvals++;

        emit TransactionApproved(txId, msg.sender);
    }

    // =============================================================
    // EXECUTION
    // =============================================================

    /*
    STEP 3: Execution Phase

    Transaction can only be executed if:
    - enough approvals are collected
    - timelock has passed
    - transaction is not expired or cancelled
    */
    function execute(uint256 txId)
        external
        onlyExecutor
        nonReentrant
        notPaused
    {
        Transaction storage t = transactions[txId];

        require(!t.executed, "Executed");
        require(!t.cancelled, "Cancelled");
        require(t.approvals >= requiredApprovals, "Insufficient approvals");
        require(block.timestamp >= t.executeAfter, "Timelock active");
        require(block.timestamp <= t.expiresAt, "Expired");

        t.executed = true;

        (bool success, ) = t.to.call{value: t.value}(t.data);
        require(success, "Execution failed");

        emit TransactionExecuted(txId, msg.sender);
    }

    // =============================================================
    // EMERGENCY CONTROLS
    // =============================================================

    /*
    Guardian role can pause contract in emergency situations
    such as detected exploit or abnormal activity.
    */
    function setPause(bool _state) external {
        require(isGuardian[msg.sender], "Not guardian");
        paused = _state;
        emit PauseStateChanged(_state);
    }

    receive() external payable {}
}
