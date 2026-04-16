// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title PanjoCoin (PNJC)
 * @author ClownCare (Charity Fund Smiledonate, Georgia)
 * @notice A finalized, fixed-supply ERC-20 utility token.
 * * INVESTMENT SUMMARY:
 * 1. FIXED TOTAL SUPPLY: The supply is capped at 1 Trillion PNJC. No inflation mechanism exists.
 * 2. RENOUNCED CONTROL: No 'Owner' or 'Admin' roles. The contract is immutable upon deployment.
 * 3. ZERO TAX POLICY: No hidden fees, reflection taxes, or transaction penalties.
 * 4. PURE COMPLIANCE: Adheres strictly to the EIP-20 standard for maximum DEX/CEX compatibility.
 */

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract PanjoCoin is IERC20 {
    // --- Token Metadata ---
    string public constant name = "PanjoCoin";
    string public constant symbol = "PNJC";
    uint8 public constant decimals = 18;

    // --- State Variables ---
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Fixed Supply: 1,000,000,000,000 tokens (scaled by 10^18)
    uint256 private constant _TOTAL_SUPPLY = 1_000_000_000_000 * 10**18;

    /**
     * @dev Sets the initial distribution upon deployment.
     * @param distributionWallet The address designated to receive the total token supply.
     */
    constructor(address distributionWallet) {
        require(distributionWallet != address(0), "PNJC: Invalid distribution address");

        _balances[distributionWallet] = _TOTAL_SUPPLY;
        emit Transfer(address(0), distributionWallet, _TOTAL_SUPPLY);
    }

    // --- Core ERC20 Logic ---

    /**
     * @notice Returns the total token supply.
     */
    function totalSupply() public pure override returns (uint256) {
        return _TOTAL_SUPPLY;
    }

    /**
     * @notice Returns the token balance of a specific address.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @notice Transfers tokens from the caller's address to a recipient.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @notice Checks the amount of tokens a spender is authorized to use on behalf of an owner.
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @notice Approves a spender to transfer a specific amount of tokens.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @notice Executes a transfer on behalf of a user, given prior approval.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }

    // --- Internal Operations ---

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from zero address");
        require(recipient != address(0), "ERC20: transfer to zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from zero address");
        require(spender != address(0), "ERC20: approve to zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
