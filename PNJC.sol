// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title PanjoCoin (PNJC) - Fixed Supply: 1 Trillion
 * @dev ERC20 token with Burn, BurnFrom, Permit (EIP-2612), safe approve, and capped supply.
 * Features:
 * - Total Supply: Fixed at 1,000,000,000,000 (10^12) * 10^18 decimals.
 * - Gas Optimized: Uses 'unchecked' blocks for arithmetic efficiency.
 * - Decentralized: No owner, no minting after deployment.
 * - Flattened: Single file for easy Etherscan verification.
 */
contract PanjoCoin {
    // ================= TOKEN METADATA =================
    string public constant name = "PanjoCoin";
    string public constant symbol = "PNJC";
    uint8 public constant decimals = 18;

    // ================= CONSTANTS (FIXED SUPPLY) =================
    // 1,000,000,000,000 * 10^18
    uint256 public constant TOTAL_SUPPLY_CAP = 1_000_000_000_000 * 10**uint256(decimals);

    // ================= STATE VARIABLES =================
    uint256 private _totalSupply;
    uint256 public immutable maxSupply; 
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // ================= PERMIT STORAGE (EIP-2612) =================
    mapping(address => uint256) public nonces;
    bytes32 public immutable DOMAIN_SEPARATOR;
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    // ================= EVENTS =================
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // ================= CONSTRUCTOR =================
    /**
     * @dev Mints the total fixed supply to the deployer's address.
     * Initializes the EIP-712 Domain Separator for gasless approvals.
     */
    constructor() {
        maxSupply = TOTAL_SUPPLY_CAP;

        uint256 chainId;
        assembly { chainId := chainid() }

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );

        // Mint exactly 1,000,000,000,000 tokens to the deployer
        _mint(msg.sender, TOTAL_SUPPLY_CAP);
    }

    // ================= ERC20 READ FUNCTIONS =================
    function totalSupply() external view returns (uint256) { return _totalSupply; }
    function balanceOf(address account) external view returns (uint256) { return _balances[account]; }
    function allowance(address owner, address spender) external view returns (uint256) { return _allowances[owner][spender]; }

    // ================= ERC20 WRITE FUNCTIONS =================
    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= amount, "ERC20: insufficient allowance");
        _approve(from, msg.sender, currentAllowance - amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Standard approve with protection against the approve race condition.
     * Users must reset allowance to 0 before setting a new value.
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        require(spender != address(0), "ERC20: zero address");
        require(amount == 0 || _allowances[msg.sender][spender] == 0, "ERC20: reset allowance first");
        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }

    // ================= BURN FUNCTIONS =================
    /**
     * @dev Destroys `amount` tokens from the caller's account, reducing total supply.
     */
    function burn(uint256 amount) external { _burn(msg.sender, amount); }

    /**
     * @dev Destroys `amount` tokens from `account` using the allowance mechanism.
     */
    function burnFrom(address account, uint256 amount) external {
        uint256 currentAllowance = _allowances[account][msg.sender];
        require(currentAllowance >= amount, "ERC20: burn exceeds allowance");
        _approve(account, msg.sender, currentAllowance - amount);
        _burn(account, amount);
    }

    // ================= PERMIT (EIP-2612) =================
    /**
     * @dev Allows users to approve spending via a signature (gasless approvals).
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v, bytes32 r, bytes32 s
    ) external {
        require(block.timestamp <= deadline, "ERC20: expired");
        require(value <= maxSupply, "ERC20: value too large");

        bytes32 structHash = keccak256(
            abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline)
        );
        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
        address signer = ecrecover(hash, v, r, s);
        require(signer == owner && signer != address(0), "ERC20: invalid signature");

        _approve(owner, spender, value);
    }

    // ================= INTERNAL FUNCTIONS =================
    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "ERC20: zero address");
        uint256 balance = _balances[from];
        require(balance >= amount, "ERC20: exceeds balance");
        
        // Unchecked for gas optimization since the check above prevents underflow
        unchecked { 
            _balances[from] = balance - amount; 
            _balances[to] += amount; 
        }
        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: zero address");
        require(_totalSupply + amount <= maxSupply, "ERC20: max supply exceeded");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        uint256 balance = _balances[account];
        require(balance >= amount, "ERC20: burn exceeds balance");
        
        // Unchecked for gas optimization
        unchecked { 
            _balances[account] = balance - amount; 
            _totalSupply -= amount; 
        }
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0) && spender != address(0), "ERC20: zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
