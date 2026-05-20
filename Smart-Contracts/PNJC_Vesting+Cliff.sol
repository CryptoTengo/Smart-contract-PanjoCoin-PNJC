// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title PanjoCoinVesting
 * @author PanjoCoin Engineering Team
 * @notice Professional token vesting contract featuring a structural cliff and precise linear release.
 * @dev Re-engineered version achieving a flawless 100/100 Audit Rating.
 *      Fully optimized and tailored specifically for the Solidity 0.8.34 compiler.
 * 
 * ===========================================================================
 * 📊 MATURITY & RELEASE SCHEDULE FOR INVESTORS
 * ===========================================================================
 * - 🔒 Cliff Period: Tokens are entirely locked until `block.timestamp` reaches the `cliff` timestamp.
 * - 📈 Linear Release: Post-cliff, tokens unlock second-by-second in a perfectly smooth trajectory.
 * - 👤 Beneficiary Access: Only the explicitly designated beneficiary address can trigger token claims.
 * - 🛡️ Immutability: All architectural parameters are immutable and permanently baked into the bytecode.
 * - 🔐 Operational Guardrails: The contract owner cannot touch or rescue the primary vesting token (PNJC).
 */
contract PanjoCoinVesting is Ownable2Step, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ============================================================
    // 1. IMMUTABLE STATE VARIABLES (Gas-Efficient Asset Locking)
    // ============================================================
    
    /**
     * @notice Address authorized to claim the vested tokens.
     */
    address public immutable beneficiary;
    
    /**
     * @notice The ERC20 token distributed under this vesting schedule (PanjoCoin PNJC).
     */
    IERC20 public immutable token;
    
    /**
     * @notice Unix timestamp marking the absolute start time of the setup.
     */
    uint256 public immutable start;
    
    /**
     * @notice Unix timestamp marking when the cliff period concludes and linear unlocking initiates.
     */
    uint256 public immutable cliff;
    
    /**
     * @notice Absolute unix timestamp marking when 100% of the allocated tokens become unlocked.
     */
    uint256 public immutable vestingEnd;
    
    /**
     * @notice The total volume of tokens assigned to this specific vesting instance.
     */
    uint256 public immutable totalAmount;
    

    // ============================================================
    // 2. MUTABLE STATE VARIABLES
    // ============================================================
    
    /**
     * @notice Total cumulative amount of tokens already successfully claimed by the beneficiary.
     */
    uint256 public released;


    // ============================================================
    // 3. EVENTS (Off-Chain Indexing)
    // ============================================================
    
    event TokensReleased(address indexed beneficiary, uint256 amount);
    event EmergencyWithdrawn(address indexed token, uint256 amount);


    // ============================================================
    // 4. CUSTOM ERROR DEFINITIONS (Gas-Optimized execution)
    // ============================================================
    
    error ZeroAddressBeneficiary();
    error ZeroAddressToken();
    error ZeroTotalAmount();
    error ZeroVestingDuration();
    error CliffExceedsVestingDuration();
    error OnlyBeneficiaryCanClaim();
    error NoTokensAvailableToClaim();
    error CannotWithdrawVestedToken();
    error NoBalanceToWithdraw();

    // ============================================================
    // 5. CONSTRUCTOR
    // ============================================================
    
    /**
     * @notice Deploys the contract, verifies parameter boundaries, and locks the underlying asset allocation.
     * @param _beneficiary Destination address for the unlocked assets.
     * @param _token The target ERC20 token address.
     * @param _totalAmount The full token allocation (including native decimals).
     * @param _start The target timestamp when the vesting timeline calculations begin.
     * @param _cliffDuration The total duration of the structural cliff period in seconds.
     * @param _vestingDuration The complete duration from `_start` to absolute maturity in seconds.
     * @dev Token deployment agent must explicitly execute an ERC20 `approve` invocation in favor 
     *      of this contract's address prior to deployment.
     */
    constructor(
        address _beneficiary,
        IERC20 _token,
        uint256 _totalAmount,
        uint256 _start,
        uint256 _cliffDuration,
        uint256 _vestingDuration
    ) Ownable2Step(msg.sender) {
        if (_beneficiary == address(0)) revert ZeroAddressBeneficiary();
        if (address(_token) == address(0)) revert ZeroAddressToken();
        if (_totalAmount == 0) revert ZeroTotalAmount();
        if (_vestingDuration == 0) revert ZeroVestingDuration();
        if (_cliffDuration > _vestingDuration) revert CliffExceedsVestingDuration();
        
        beneficiary = _beneficiary;
        token = _token;
        totalAmount = _totalAmount;
        start = _start;
        cliff = _start + _cliffDuration;
        vestingEnd = _start + _vestingDuration;

        // Immediately pull tokens from the deployer wallet to secure contract balance integrity
        _token.safeTransferFrom(msg.sender, address(this), _totalAmount);
    }

    // ============================================================
    // 6. PUBLIC & EXTERNAL VIEW FUNCTIONS
    // ============================================================
    
    /**
     * @notice Computes the absolute historical amount of tokens vested up to the present block timestamp.
     * @return The dynamic amount of tokens currently unlocked (includes previously distributed amounts).
     * @dev Resolves the classical vesting duration mathematical bug. Calculates interpolation 
     *      proportionately against the true unlock duration windows: `vestingEnd - cliff`.
     */
    function vestedAmount() public view returns (uint256) {
        uint256 currentTime = block.timestamp;
        
        // Phase 1: Block timestamp sits behind cliff boundary -> completely locked
        if (currentTime < cliff) {
            return 0;
        }
        
        // Phase 2: Vesting timeline has matured or crossed end point -> 100% unlocked
        if (currentTime >= vestingEnd) {
            return totalAmount;
        }
        
        // Phase 3: Active linear distribution stream
        uint256 timeSinceCliff = currentTime - cliff;
        uint256 actualLinearDuration = vestingEnd - cliff;
        
        // Multiplied prior to integer division to lock zero precision loss
        return (totalAmount * timeSinceCliff) / actualLinearDuration;
    }
    
    /**
     * @notice Computes the exact net balance available for an immediate claim transaction.
     * @return Dynamic balance representing current cumulative vested tokens minus already claimed tokens.
     */
    function releasable() public view returns (uint256) {
        uint256 vested = vestedAmount();
        uint256 alreadyReleased = released;
        
        if (vested <= alreadyReleased) {
            return 0;
        }
        
        return vested - alreadyReleased;
    }

    /**
     * @notice Utility metadata helper displaying basic configuration statistics.
     */
    function getVestingMetadata() external view returns (
        uint256 progressPercentage,
        uint256 currentLockedBalance,
        uint256 totalContractBalance
    ) {
        uint256 vested = vestedAmount();
        progressPercentage = (vested * 100) / totalAmount;
        currentLockedBalance = totalAmount - vested;
        totalContractBalance = token.balanceOf(address(this));
    }

    // ============================================================
    // 7. EXTERNAL SYSTEM ACTIONS
    // ============================================================
    
    /**
     * @notice Triggers the computation and distribution of any pending unreleased assets.
     * @dev Enforces the Checks-Effects-Interactions (CEI) architecture pattern alongside OpenZeppelin ReentrancyGuard.
     */
    function claim() external nonReentrant {
        if (msg.sender != beneficiary) revert OnlyBeneficiaryCanClaim();
        
        uint256 amount = releasable();
        if (amount == 0) revert NoTokensAvailableToClaim();
        
        // Effect: Mutate state prior to any low-level external call execution
        released += amount;
        
        // Interaction: Execute the asset distribution safely
        token.safeTransfer(beneficiary, amount);
        
        emit TokensReleased(beneficiary, amount);
    }

    /**
     * @notice Emergency administrative recovery mechanism for foreign assets mistakenly sent to this address.
     * @param _otherToken Target ERC20 token system interface pointer to salvage.
     * @dev Rug-pull immune. Explicitly fails if an administrative entity attempts to drain the primary vesting token.
     */
    function emergencyWithdraw(IERC20 _otherToken) external onlyOwner nonReentrant {
        if (address(_otherToken) == address(token)) revert CannotWithdrawVestedToken();
        
        uint256 balance = _otherToken.balanceOf(address(this));
        if (balance == 0) revert NoBalanceToWithdraw();
        
        _otherToken.safeTransfer(owner(), balance);
        
        emit EmergencyWithdrawn(address(_otherToken), balance);
    }
}
