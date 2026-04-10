// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/**
 * @title PanjoCoin (PNJC) - High-Fidelity Technical Refactor
 * @notice A decentralized ERC-20 asset featuring automated Fair-Launch constraints.
 * @dev Engineered for EVM Cancun. This contract implements a Zero-Admin architecture
 * to eliminate centralization risks (No Mint, No Pause, No Blacklist).
 */

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

/**
 * @dev Standardized ERC-20 Logic (OpenZeppelin Derived)
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) { return _name; }
    function symbol() public view virtual returns (string memory) { return _symbol; }
    function decimals() public view virtual returns (uint8) { return 18; }
    function totalSupply() public view virtual returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view virtual returns (uint256) { return _balances[account]; }

    function transfer(address to, uint256 value) public virtual returns (bool) {
        _transfer(_msgSender(), to, value);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public virtual returns (bool) {
        _approve(_msgSender(), spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        _spendAllowance(from, _msgSender(), value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal virtual {
        require(from != address(0), "ERC20: transfer from zero");
        require(to != address(0), "ERC20: transfer to zero");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= value, "ERC20: insufficient balance");
        unchecked {
            _balances[from] = fromBalance - value;
            _balances[to] += value;
        }
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        require(account != address(0), "ERC20: mint to zero");
        _totalSupply += value;
        unchecked { _balances[account] += value; }
        emit Transfer(address(0), account, value);
    }

    function _approve(address owner, address spender, uint256 value) internal virtual {
        require(owner != address(0), "ERC20: approve from zero");
        require(spender != address(0), "ERC20: approve to zero");
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= value, "ERC20: insufficient allowance");
            unchecked { _approve(owner, spender, currentAllowance - value); }
        }
    }
}

/**
 * @dev Final Implementation with Fair-Launch Restrictions.
 */
contract PanjoCoin is ERC20 {
    
    // Constant parameters to optimize gas consumption
    uint256 private constant _MAX_SUPPLY = 1_000_000_000_000 * 10**18;
    uint256 public constant MAX_TX_LIMIT = _MAX_SUPPLY / 200;      // 0.5% Anti-Dump
    uint256 public constant MAX_WALLET_LIMIT = _MAX_SUPPLY / 100;  // 1.0% Anti-Whale
    uint256 public constant TRADE_COOLDOWN = 30 seconds;           // Anti-Bot latency

    address public immutable deployer;
    uint256 public immutable launchTimestamp;
    mapping(address => uint256) private _lastAction;

    constructor() ERC20("PanjoCoin", "PNJC") {
        deployer = msg.sender;
        launchTimestamp = block.timestamp;
        _mint(msg.sender, _MAX_SUPPLY);
    }

    /**
     * @notice Internal transfer override to enforce temporal constraints.
     * @dev Restrictions automatically expire 24 hours post-deployment.
     * The deployer is excluded from constraints to facilitate initial liquidity seeding.
     */
    function _transfer(address from, address to, uint256 amount) internal override {
        // Enforce Fair-Launch logic for the initial 24-hour window
        if (block.timestamp < launchTimestamp + 24 hours && from != deployer && to != deployer) {
            
            // Transaction Velocity Guard
            require(amount <= MAX_TX_LIMIT, "FairLaunch: Amount exceeds MAX_TX_LIMIT");
            
            // Saturation Guard (Wallet Cap)
            if (to != address(this)) {
                require(balanceOf(to) + amount <= MAX_WALLET_LIMIT, "FairLaunch: Wallet exceeds MAX_WALLET_LIMIT");
            }

            // High-Frequency Trading (HFT) / Bot Mitigation
            require(block.timestamp >= _lastAction[from] + TRADE_COOLDOWN, "FairLaunch: Cooldown active");
            _lastAction[from] = block.timestamp;
        }

        super._transfer(from, to, amount);
    }
}
