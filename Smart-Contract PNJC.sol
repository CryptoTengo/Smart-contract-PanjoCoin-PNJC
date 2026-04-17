// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*//////////////////////////////////////////////////////////////
                     INTERFACES & BASE LOGIC
//////////////////////////////////////////////////////////////*/

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
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

/*//////////////////////////////////////////////////////////////
                         EIP-712 & PERMIT
//////////////////////////////////////////////////////////////*/

/**
 * @dev Implementation of the EIP712 domain separator for signed typed data.
 */
abstract contract EIP712 {
    bytes32 private immutable _DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    constructor(string memory name, string memory version) {
        _CACHED_CHAIN_ID = block.chainid;
        _DOMAIN_SEPARATOR = _buildDomainSeparator(name, version);
    }

    function _buildDomainSeparator(string memory name, string memory version) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                block.chainid,
                address(this)
            )
        );
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        return block.chainid == _CACHED_CHAIN_ID ? _DOMAIN_SEPARATOR : _buildDomainSeparator("PanjoCoin", "1");
    }
}

/*//////////////////////////////////////////////////////////////
                        MAIN ERC20 LOGIC
//////////////////////////////////////////////////////////////*/

contract PanjoCoin is Context, IERC20, IERC20Metadata, EIP712 {
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    mapping(address => uint256) public nonces;

    uint256 private _totalSupply;
    
    // Token Constants
    string private constant _NAME = "PanjoCoin";
    string private constant _SYMBOL = "PNJC";
    uint256 public constant MAX_SUPPLY = 1_000_000_000_000 * 10**18;

    // EIP-2612 Permit Typehash
    bytes32 private constant PERMIT_TYPEHASH = 
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    event Burn(address indexed from, uint256 amount);
    event InitialDistribution(address indexed wallet, uint256 amount);

    /**
     * @dev Sets the initial supply and assigns it to the distribution wallet.
     * @param distributionWallet The address receiving the total supply.
     */
    constructor(address distributionWallet) EIP712(_NAME, "1") {
        require(distributionWallet != address(0), "INVALID_WALLET");

        _totalSupply = MAX_SUPPLY;
        _balances[distributionWallet] = MAX_SUPPLY;

        emit Transfer(address(0), distributionWallet, MAX_SUPPLY);
        emit InitialDistribution(distributionWallet, MAX_SUPPLY);
    }

    /*--- Standard Getters ---*/

    function name() public pure override returns (string memory) { return _NAME; }
    function symbol() public pure override returns (string memory) { return _SYMBOL; }
    function decimals() public pure override returns (uint8) { return 18; }
    function totalSupply() public view override returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }

    /**
     * @dev Basic transfer function.
     */
    function transfer(address to, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev Approval mechanism for third-party spending.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev Transfer from one account to another using the allowance mechanism.
     */
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        uint256 currentAllowance = _allowances[from][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ALLOWANCE_LOW");
            unchecked {
                _approve(from, _msgSender(), currentAllowance - amount);
            }
        }
        _transfer(from, to, amount);
        return true;
    }

    /*--- Permit (EIP-2612) ---*/

    /**
     * @dev Allows gasless approval via EIP-712 signatures.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(block.timestamp <= deadline, "PERMIT_EXPIRED");

        uint256 nonce;
        unchecked {
            nonce = nonces[owner]++;
        }

        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonce, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), structHash));

        address signer = ecrecover(digest, v, r, s);
        require(signer != address(0) && signer == owner, "INVALID_SIGNATURE");

        _approve(owner, spender, value);
    }

    /*--- Token Burning ---*/

    /**
     * @dev Permanently destroys 'amount' of tokens from the caller's balance.
     */
    function burn(uint256 amount) external {
        address account = _msgSender();
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BURN_EXCEEDS_BALANCE");

        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Burn(account, amount);
        emit Transfer(account, address(0), amount);
    }

    /*--- Internal Helpers ---*/

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "FROM_ZERO");
        require(to != address(0), "TO_ZERO");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "TRANSFER_EXCEEDS_BALANCE");

        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "OWNER_ZERO");
        require(spender != address(0), "SPENDER_ZERO");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
