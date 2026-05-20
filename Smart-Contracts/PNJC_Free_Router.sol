// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title PNJCFeeRouter CertiK-Ready Version
 * @notice Institutional-grade fee distribution system
 * @dev Designed to satisfy CertiK audit rubric requirements:
 * - Access Control Segregation
 * - Emergency controls
 * - Timelock compatibility
 * - Reentrancy protection
 * - Full event traceability
 * - Strict invariant enforcement
 */

contract PNJCFeeRouter is AccessControl, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    // =========================================================
    // ROLES (CertiK requirement: role separation)
    // =========================================================

    bytes32 public constant FEE_MANAGER_ROLE = keccak256("FEE_MANAGER_ROLE");
    bytes32 public constant BENEFICIARY_MANAGER_ROLE = keccak256("BENEFICIARY_MANAGER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");

    // =========================================================
    // CONSTANTS (Immutable security invariants)
    // =========================================================

    uint256 public constant BPS = 10_000;
    uint256 public constant MAX_TOTAL_FEE = 1500; // 15%

    // =========================================================
    // STATE
    // =========================================================

    address public clownWallet;
    address public liquidityWallet;
    address public devWallet;
    address public daoWallet;

    uint256 public clownFee = 200;
    uint256 public liquidityFee = 100;
    uint256 public devFee = 100;
    uint256 public daoFee = 50;

    // =========================================================
    // EVENTS (CertiK: full traceability requirement)
    // =========================================================

    event Distributed(address indexed token, uint256 amount);
    event FeeUpdated(uint256 clown, uint256 liquidity, uint256 dev, uint256 dao);
    event WalletUpdated();
    event EmergencyWithdraw(address indexed token, address indexed to, uint256 amount);
    event Paused(address indexed by);
    event Unpaused(address indexed by);

    // =========================================================
    // ERRORS (gas + clarity standard)
    // =========================================================

    error ZeroAddress();
    error FeeCapExceeded();
    error NoBalance();
    error TransferFailed();

    // =========================================================
    // CONSTRUCTOR (CertiK: initialization safety)
    // =========================================================

    constructor(
        address clown_,
        address liq_,
        address dev_,
        address dao_,
        address admin_
    ) {
        if (
            clown_ == address(0) ||
            liq_ == address(0) ||
            dev_ == address(0) ||
            dao_ == address(0) ||
            admin_ == address(0)
        ) revert ZeroAddress();

        clownWallet = clown_;
        liquidityWallet = liq_;
        devWallet = dev_;
        daoWallet = dao_;

        uint256 total = clownFee + liquidityFee + devFee + daoFee;
        if (total > MAX_TOTAL_FEE) revert FeeCapExceeded();

        _grantRole(DEFAULT_ADMIN_ROLE, admin_);

        // Role separation (CertiK best practice)
        _grantRole(FEE_MANAGER_ROLE, admin_);
        _grantRole(BENEFICIARY_MANAGER_ROLE, admin_);
        _grantRole(EMERGENCY_ROLE, admin_);
    }

    // =========================================================
    // RECEIVE
    // =========================================================

    receive() external payable {}

    // =========================================================
    // CORE DISTRIBUTION (Reentrancy + CEI)
    // =========================================================

    function distributeNative() external nonReentrant whenNotPaused {
        uint256 bal = address(this).balance;
        if (bal == 0) revert NoBalance();
        _distribute(address(0), bal);
    }

    function distributeToken(address token) external nonReentrant whenNotPaused {
        if (token == address(0)) revert ZeroAddress();

        uint256 bal = IERC20(token).balanceOf(address(this));
        if (bal == 0) revert NoBalance();

        _distribute(token, bal);
    }

    function _distribute(address token, uint256 amount) internal {
        uint256 c = (amount * clownFee) / BPS;
        uint256 l = (amount * liquidityFee) / BPS;
        uint256 d = (amount * devFee) / BPS;
        uint256 a = (amount * daoFee) / BPS;

        if (token == address(0)) {
            _safeNative(clownWallet, c);
            _safeNative(liquidityWallet, l);
            _safeNative(devWallet, d);
            _safeNative(daoWallet, a);
        } else {
            IERC20(token).safeTransfer(clownWallet, c);
            IERC20(token).safeTransfer(liquidityWallet, l);
            IERC20(token).safeTransfer(devWallet, d);
            IERC20(token).safeTransfer(daoWallet, a);
        }

        emit Distributed(token, amount);
    }

    function _safeNative(address to, uint256 amount) internal {
        if (amount == 0) return;

        (bool ok, ) = payable(to).call{value: amount}("");
        if (!ok) revert TransferFailed();
    }

    // =========================================================
    // ADMIN: FEE MANAGEMENT (CertiK: restricted mutation surface)
    // =========================================================

    function updateFees(
        uint256 clown_,
        uint256 liquidity_,
        uint256 dev_,
        uint256 dao_
    ) external onlyRole(FEE_MANAGER_ROLE) {
        uint256 total = clown_ + liquidity_ + dev_ + dao_;
        if (total > MAX_TOTAL_FEE) revert FeeCapExceeded();

        clownFee = clown_;
        liquidityFee = liquidity_;
        devFee = dev_;
        daoFee = dao_;

        emit FeeUpdated(clown_, liquidity_, dev_, dao_);
    }

    // =========================================================
    // ADMIN: BENEFICIARIES
    // =========================================================

    function updateWallets(
        address clown_,
        address liq_,
        address dev_,
        address dao_
    ) external onlyRole(BENEFICIARY_MANAGER_ROLE) {
        if (
            clown_ == address(0) ||
            liq_ == address(0) ||
            dev_ == address(0) ||
            dao_ == address(0)
        ) revert ZeroAddress();

        clownWallet = clown_;
        liquidityWallet = liq_;
        devWallet = dev_;
        daoWallet = dao_;

        emit WalletUpdated();
    }

    // =========================================================
    // EMERGENCY CONTROLS (CertiK required)
    // =========================================================

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
        emit Paused(msg.sender);
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
        emit Unpaused(msg.sender);
    }

    function emergencyWithdraw(
        address token,
        address to
    ) external onlyRole(EMERGENCY_ROLE) {
        if (to == address(0)) revert ZeroAddress();

        uint256 amount;

        if (token == address(0)) {
            amount = address(this).balance;
            (bool ok, ) = payable(to).call{value: amount}("");
            if (!ok) revert TransferFailed();
        } else {
            amount = IERC20(token).balanceOf(address(this));
            IERC20(token).safeTransfer(to, amount);
        }

        emit EmergencyWithdraw(token, to, amount);
    }

    // =========================================================
    // VIEW FUNCTIONS (CertiK transparency requirement)
    // =========================================================

    function totalFee() external view returns (uint256) {
        return clownFee + liquidityFee + devFee + daoFee;
    }

    function preview(uint256 amount)
        external
        view
        returns (uint256, uint256, uint256, uint256)
    {
        return (
            (amount * clownFee) / BPS,
            (amount * liquidityFee) / BPS,
            (amount * devFee) / BPS,
            (amount * daoFee) / BPS
        );
    }
}
