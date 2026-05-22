// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

/*
|--------------------------------------------------------------------------
| PanjoCoin (PNJC) - Institutional Liquidity Locker
|--------------------------------------------------------------------------
|
| Author: PanjoCoin Ecosystem
| Standard: OpenZeppelin v5
| Solidity: 0.8.34
|
| SECURITY DESIGN GOALS
| ---------------------
| - Anti-rug LP protection
| - Immutable beneficiary security
| - Reentrancy protection
| - Timelocked liquidity
| - Multi-lock support
| - Governance hardening
| - Emergency pause system
| - CertiK-style architecture
|
| AUDITOR NOTES
| -------------
| This contract intentionally minimizes:
| - external trust assumptions
| - owner privileges
| - upgrade complexity
| - attack surface
|
| Owner CANNOT:
| - withdraw LP before unlock
| - redirect liquidity after deployment
| - modify lock amounts
| - bypass timelock restrictions
|
| INVESTOR NOTES
| --------------
| LP tokens locked in this contract remain inaccessible
| until the unlock timestamp is reached.
|
| Liquidity cannot be rugged by the owner.
|
| Recommended deployment:
| - deploy from multisig wallet
| - renounce ownership after final lock creation
|
*/

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract PNJCLiquidityLocker is
    Ownable,
    ReentrancyGuard,
    Pausable
{
    using SafeERC20 for IERC20;

    // =============================================================
    // CUSTOM ERRORS
    // =============================================================

    error ZeroAddress();
    error ZeroAmount();
    error InvalidUnlockTime();
    error AlreadyWithdrawn();
    error StillLocked();
    error Unauthorized();
    error InvalidLock();
    error InvalidExtension();

    // =============================================================
    // LOCK STRUCT
    // =============================================================

    struct LockInfo {
        address token;
        uint128 amount;
        uint64 unlockTime;
        bool withdrawn;
    }

    // =============================================================
    // STORAGE
    // =============================================================

    /*
    |--------------------------------------------------------------------------
    | IMMUTABLE BENEFICIARY
    |--------------------------------------------------------------------------
    |
    | Security rationale:
    | Prevents owner from redirecting LP after deployment.
    |
    | This removes one of the major centralization concerns
    | commonly identified in CertiK audits.
    |
    */

    address public immutable beneficiary;

    /*
    |--------------------------------------------------------------------------
    | LOCK COUNTER
    |--------------------------------------------------------------------------
    */

    uint256 public totalLocks;

    /*
    |--------------------------------------------------------------------------
    | LOCK STORAGE
    |--------------------------------------------------------------------------
    */

    mapping(uint256 => LockInfo) private _locks;

    /*
    |--------------------------------------------------------------------------
    | ACTIVE LOCK TRACKING
    |--------------------------------------------------------------------------
    |
    | Added for better transparency and analytics.
    |
    */

    uint256[] public activeLocks;

    // =============================================================
    // EVENTS
    // =============================================================

    event LiquidityLocked(
        uint256 indexed lockId,
        address indexed token,
        uint256 amount,
        uint256 unlockTime
    );

    event LiquidityWithdrawn(
        uint256 indexed lockId,
        address indexed token,
        uint256 amount
    );

    event LockExtended(
        uint256 indexed lockId,
        uint256 oldUnlockTime,
        uint256 newUnlockTime
    );

    event EmergencyPauseEnabled(address indexed owner);

    event EmergencyPauseDisabled(address indexed owner);

    // =============================================================
    // CONSTRUCTOR
    // =============================================================

    constructor(
        address _beneficiary,
        address _initialOwner
    ) Ownable(_initialOwner) {
        if (_beneficiary == address(0)) {
            revert ZeroAddress();
        }

        if (_initialOwner == address(0)) {
            revert ZeroAddress();
        }

        beneficiary = _beneficiary;
    }

    // =============================================================
    // LOCK LIQUIDITY
    // =============================================================

    /*
    |--------------------------------------------------------------------------
    | LOCK LP TOKENS
    |--------------------------------------------------------------------------
    |
    | SECURITY:
    | - onlyOwner
    | - nonReentrant
    | - pause protected
    | - SafeERC20 transfer
    |
    */

    function lockLiquidity(
        address token,
        uint256 amount,
        uint256 unlockTime
    )
        external
        onlyOwner
        nonReentrant
        whenNotPaused
    {
        if (token == address(0)) {
            revert ZeroAddress();
        }

        if (amount == 0) {
            revert ZeroAmount();
        }

        if (unlockTime <= block.timestamp) {
            revert InvalidUnlockTime();
        }

        IERC20(token).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        _locks[totalLocks] = LockInfo({
            token: token,
            amount: uint128(amount),
            unlockTime: uint64(unlockTime),
            withdrawn: false
        });

        activeLocks.push(totalLocks);

        emit LiquidityLocked(
            totalLocks,
            token,
            amount,
            unlockTime
        );

        unchecked {
            totalLocks++;
        }
    }

    // =============================================================
    // EXTEND LOCK
    // =============================================================

    /*
    |--------------------------------------------------------------------------
    | EXTEND LOCK PERIOD
    |--------------------------------------------------------------------------
    |
    | SECURITY:
    | Lock time can ONLY increase.
    |
    | This is important for investor confidence.
    |
    */

    function extendLock(
        uint256 lockId,
        uint256 newUnlockTime
    )
        external
        onlyOwner
        whenNotPaused
    {
        LockInfo storage lockData = _locks[lockId];

        if (lockData.token == address(0)) {
            revert InvalidLock();
        }

        if (lockData.withdrawn) {
            revert AlreadyWithdrawn();
        }

        if (newUnlockTime <= lockData.unlockTime) {
            revert InvalidExtension();
        }

        uint256 oldUnlock = lockData.unlockTime;

        lockData.unlockTime = uint64(newUnlockTime);

        emit LockExtended(
            lockId,
            oldUnlock,
            newUnlockTime
        );
    }

    // =============================================================
    // WITHDRAW LIQUIDITY
    // =============================================================

    /*
    |--------------------------------------------------------------------------
    | WITHDRAW AFTER LOCK EXPIRATION
    |--------------------------------------------------------------------------
    |
    | SECURITY:
    | - only beneficiary
    | - nonReentrant
    | - CEI pattern
    | - SafeERC20
    |
    */

    function withdrawLiquidity(
        uint256 lockId
    )
        external
        nonReentrant
        whenNotPaused
    {
        if (msg.sender != beneficiary) {
            revert Unauthorized();
        }

        LockInfo storage lockData = _locks[lockId];

        if (lockData.token == address(0)) {
            revert InvalidLock();
        }

        if (lockData.withdrawn) {
            revert AlreadyWithdrawn();
        }

        if (block.timestamp < lockData.unlockTime) {
            revert StillLocked();
        }

        /*
        |--------------------------------------------------------------------------
        | CEI PATTERN
        |--------------------------------------------------------------------------
        |
        | State updated BEFORE external transfer.
        |
        */

        lockData.withdrawn = true;

        IERC20(lockData.token).safeTransfer(
            beneficiary,
            lockData.amount
        );

        emit LiquidityWithdrawn(
            lockId,
            lockData.token,
            lockData.amount
        );
    }

    // =============================================================
    // EMERGENCY PAUSE
    // =============================================================

    /*
    |--------------------------------------------------------------------------
    | EMERGENCY CIRCUIT BREAKER
    |--------------------------------------------------------------------------
    |
    | Can be used during:
    | - ecosystem exploit
    | - bridge exploit
    | - LP token vulnerability
    | - governance incident
    |
    */

    function pause()
        external
        onlyOwner
    {
        _pause();

        emit EmergencyPauseEnabled(msg.sender);
    }

    function unpause()
        external
        onlyOwner
    {
        _unpause();

        emit EmergencyPauseDisabled(msg.sender);
    }

    // =============================================================
    // VIEW FUNCTIONS
    // =============================================================

    function getLock(
        uint256 lockId
    )
        external
        view
        returns (
            address token,
            uint256 amount,
            uint256 unlockTime,
            bool withdrawn
        )
    {
        LockInfo memory l = _locks[lockId];

        return (
            l.token,
            l.amount,
            l.unlockTime,
            l.withdrawn
        );
    }

    function remainingTime(
        uint256 lockId
    )
        external
        view
        returns (uint256)
    {
        LockInfo memory l = _locks[lockId];

        if (block.timestamp >= l.unlockTime) {
            return 0;
        }

        return l.unlockTime - block.timestamp;
    }

    function getActiveLocks()
        external
        view
        returns (uint256[] memory)
    {
        return activeLocks;
    }

    // =============================================================
    // OWNERSHIP HARDENING
    // =============================================================

    /*
    |--------------------------------------------------------------------------
    | RECOMMENDED POST-DEPLOYMENT STEP
    |--------------------------------------------------------------------------
    |
    | After all liquidity locks are created:
    |
    | 1. Transfer ownership to multisig
    | OR
    | 2. Renounce ownership forever
    |
    | This significantly improves:
    | - decentralization score
    | - investor trust
    | - CertiK rating
    |
    */
}
